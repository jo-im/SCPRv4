# See the Twitter API docs for more available options:
# https://dev.twitter.com/docs/api/1/get/statuses/user_timeline

module Job
  class VerticalsTwitter < Base
    attr_reader :cache_key, :partial
    @queue = "#{namespace}:rake_tasks"
    DEFAULTS = {
      :count            => 6,
      :trim_user        => 0,
      :include_rts      => 1,
      :exclude_replies  => 1,
      :include_entities => 0
    }

    #---------------
    def self.perform
      @twitter_handles = Bio.joins(:categories).map(&:twitter_handle).reject! { |v| v.blank? }
      @twitter_handles.each do |handle|
        task = new(handle)
        if tweets = task.fetch
          self.cache(tweets, task.partial, task.cache_key)
          true
        end
      end
    end

    #---------------

    def initialize(screen_name, partial="/shared/widgets/cached/vertical_tweets", options={})
      @tweeter     = Tweeter.new("kpccweb")

      @screen_name = screen_name
      @cache_key   = "twitter:#{screen_name}"
      @partial     = partial
      @options     = options.reverse_merge! DEFAULTS
    end

    #---------------

    def fetch
      begin
        self.log "Fetching the latest #{@options[:count]} tweets for #{@screen_name}..."
        tweets = @tweeter.user_timeline(@screen_name, @options)
        tweets
      rescue => e
        self.log "Error: \n #{e}"
        false
      end
    end

    add_transaction_tracer :fetch, category: :task
  end # VerticalsTwitter
end # Job

