# The NPR Importer is here because NPR, through their API, gives us more
# information about a given segment than an RSS feed does.
#
# A program with its source set to "npr-api" is assumed to have segmented
# episodes. This might not always be the case with the NPR API, I really
# don't know, but we'll leave it like this until something breaks. For now
# we assume that every program has episodes, and every segment has an episode.
#
# We are also assuming that all segments in an episode will have audio.
#
# http://www.npr.org/api/mappingCodes.php
class NprProgramImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  SOURCE = "npr-api"


  class << self
    def sync(external_program)
      self.new(external_program).sync
    end
  end



  def initialize(external_program)
    @external_program = external_program
  end


  def sync
    Rails.logger.debug "Starting sync for #{ @external_program.title }"
    # `date=current` returns the program's latest episode's segments.
    # Set limit to 20 to return as many segments as possible for the
    # episode.
    stories   = []
    offset    = 0

    begin
      response  = fetch_stories(offset)
      stories   += response
      offset    += 20
    end until response.size < 20

    # If there are no segments then forget about it.
    # Even if an episode is available in the NPR API, its audio may
    # not be available yet.
    return false if stories.empty? || !audio_available?(stories)

    # If there's not a show, then we should abort because the
    # imported segment will never get seen anyways, which would
    # be a hidden and potentially confusing bug.
    #
    # If there are segments with their "stream" permission set to "false",
    # then we'll go ahead with the sync, but just won't import those ones.
    show = stories.first.shows.last
    return false if !show

    external_episode = find_or_create_external_episode(show)

    # What segments have we already created in a previous run?
    existing_segment_ids = external_episode.segments.collect(&:external_id).map { |id| id.to_i }

    stories.each_with_index do |story, i|
      if existing_segment_ids.include?(story.id)
        Rails.logger.debug "Skipping existing story #{ story.id }"
        next
      end

      # Make sure there's usable audio before we build the segment
      audio = []
      story.audio.select { |a| stream_allowed?(a) && !a.formats.empty? && !a.formats.mp3s.empty? }
      .each_with_index do |remote_audio, i|
        if mp3 = remote_audio.formats.mp3s.find { |m| m.type == "mp3" }
          audio << {
            url:          mp3.content,
            duration:     remote_audio.duration,
            description:  remote_audio.description || remote_audio.title || story.title,
            byline:       remote_audio.rightsHolder || "NPR",
            position:     i,
          }
        end
      end

      if audio.empty?
        Rails.logger.debug "Skipping segment for #{ story.id }. No audio yet."
        next
      end

      Rails.logger.debug "Building segment for #{ story.id } (#{story.shows.last.try(:segNum)})"

      # Wrap all of our segment creation in a transaction, to try and keep
      # from ending up with half-formed segments
      ExternalProgram.transaction do
        external_segment = @external_program.segments.create(
          title:        story.title,
          teaser:       story.teaser,
          published_at: story.pubDate,
          external_url: story.link_for("html"),
          external_id:  story.id,
        )

        # There were some segments coming through without a "shows" property.
        # I'm not sure what that means, but we'll import it anyways and just
        # put it at the end of the list.
        external_episode.external_episode_segments.create(
          segment: external_segment,
          position:         story.shows.last.try(:segNum) || stories.length + i,
        )

        # Now create our audio objects
        audio.each do |a|
          external_segment.audio.create(a)
        end
      end

      # Update timestamp on the episode to make sure new segments bust caching
      external_episode.touch
    end

    true
  end

  add_transaction_tracer :sync, category: :task

  private

  def fetch_stories(offset)
    NPR::Story.where(
      id:   @external_program.external_id,
      date: "current"
    ).set(requiredAssets: "audio")
    .limit(20).offset(offset)
    .to_a.select { |s| can_stream?(s) }
  end

  # For NPR, we kind of have to make-up these episodes, since NPR
  # doesn't really keep track of the shows, except for the air-date
  # and as a means to group together segments.
  def find_or_create_external_episode(show)
    ep = @external_program.episodes.find_by(air_date:show.showDate)

    if !ep
      ep = @external_program.episodes.create(
        :title      => "#{@external_program.title} for " +
                       show.showDate.strftime("%A, %B %e, %Y"),
        :air_date   => show.showDate,
      )
    end

    ep
  end

  def can_stream?(story)
    story.audio.any? { |a| stream_allowed?(a) }
  end

  def stream_allowed?(audio)
    audio.permissions.stream?
  end

  # Do any of these stories have audio available for streaming?
  def audio_available?(stories)
    stories.any? { |story|
      story.audio.present? &&
      story.audio.any? { |a| !a.formats.empty? && stream_allowed?(a) && a.formats.mp3s.find { |m| m.type == "mp3" } }
    }
  end
end
