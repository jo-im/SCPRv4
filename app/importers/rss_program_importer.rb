require 'rss'
require 'open-uri'

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
    feed = nil
    begin
      open(@external_program.podcast_url, :allow_redirections => :all, :read_timeout => 30) do |rss|
        feed = RSS::Parser.parse(rss, false)
      end
    rescue => e
      warn "Error caught in RSSProgramImporter.sync: #{e}"
      self.log "Could not import from the given RSS feed: #{e}"
      NewRelic.log_error(e)
    end

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
      audio = Audio.new(
        :url            => item.enclosure.url,
        :description    => item.title,
        :byline         => @external_program.title,
        :position       => 0
      )

      # We only want to save this audio if the audio file can actually be
      # reached. We are really not trusting the RSS feed. We had some problems
      # with Radiolab where the audio file couldn't be reached, which resulted
      # in some missing duration/size information. So now we want to ping the
      # file before saving.
      if !audio.file.present?
        log "Audio file couldn't be reached. This item won't be imported. " \
            "(#{item.enclosure.url})"

        next
      end

      # No need to build the episode unless the audio is available, so we're
      # waiting until after the audio presence check to build it.
      episode = @external_program.episodes.build(
        :title       => item.title,
        :summary     => item.description,
        :air_date    => item.pubDate,
        :external_id => item.guid.content
      )

      episode.audio << audio
    end

    @external_program.save!
    # temporary measure to prevent duplicates until we can figure out where the problem lies
    @external_program.episodes.duplicates.destroy_all
  end

  add_transaction_tracer :sync, category: :task


  private

  def episode_exists?(item)
    ExternalEpisode.exists?(
      :external_program_id    => @external_program.id,
      :title                  => item.title
    )
  end

  def can_import?(item)
    item.enclosure.present? &&
    item.enclosure.type =~ /audio/ &&
    !episode_exists?(item)
  end
end
