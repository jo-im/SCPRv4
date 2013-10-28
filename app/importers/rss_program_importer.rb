require 'rss'

# We assume that the RSS feeds (podcast) contain an entire episode in each
# item. I don't know if this is always necessarily true.
class RssProgramImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  extend LogsAsTask
  logs_as_task

  class << self
    def sync(external_program)
      self.new(external_program).sync
    end
  end


  def initialize(external_program)
    @external_program = external_program
  end

  # We're only going to bother with the first 5 episodes
  def sync
    feed = RSS::Parser.parse(@external_program.podcast_url, false)

    if !feed || feed.items.empty?
      log "Feed is empty. Aborting. (#{@external_program.podcast_url})"
      return false
    end

    feed.items.first(5).select { |i| can_import?(i) }.each do |item|
      # Import Audio
      # We're not using the RSS enclosure length for two reasons:
      # 1. We're going to grab the file anyways to get the audio's duration,
      #    so we may as well get the actual file size as well, instead of what
      #    the feed is reporting.
      # 2. Radiolab sets all of the enclosure lengths to '0' because of its
      #    ad software. Kim knows more. Ask Kim. I'm just a dumb comment.
      audio = Audio::DirectAudio.new(
        :external_url   => item.enclosure.url,
        :description    => item.title,
        :byline         => @external_program.title,
        :position       => 0
      )

      # We only want to save this audio if the audio file can actually be
      # reached. We are really not trusting the RSS feed. We had some problems
      # with Radiolab where the audio file couldn't be reached, which resulted
      # in some missing duration/size information. So now we want to ping the
      # file before saving.
      #
      # Since we're grabbing the audio file already, we're
      # also going to just compute its information (duration and size) now,
      # instead of having to fetch it again later in a background task.
      if !audio.mp3_file.present?
        log "Audio file couldn't be reached. This item won't be imported. " \
            "(#{item.enclosure.url})"

        next
      end

      audio.compute_file_info

      # No need to build the episode unless the audio is available, so we're
      # waiting until after the audio presence check to build it.
      episode = @external_program.external_episodes.build(
        :title       => item.title,
        :summary     => item.description,
        :air_date    => item.pubDate,
        :external_id => item.guid.content
      )

      episode.audio << audio
    end

    @external_program.save!
  end

  add_transaction_tracer :sync, category: :task


  private

  def episode_exists?(item)
    ExternalEpisode.exists?(
      :external_program_id    => @external_program.id,
      :external_id            => item.guid.content
    )
  end

  def can_import?(item)
    item.enclosure.present? &&
    item.enclosure.type =~ /audio/ &&
    !episode_exists?(item)
  end
end
