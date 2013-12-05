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
      #@twitter_handles = Bio.joins(:categories).map(&:twitter_handle).reject! { |v| v.blank? }
      Category.all.each do |category|
        @tweet_list = []
        @twitter_handles = category.bios.map(&:twitter_handle)
        @twitter_handles.each do |handle|
          task = new(handle)
          if tweets = task.fetch
            tweets.each_with_object(@tweet_list) { |tweet, list| list.push(tweet) }
          end
        end
        @sorted_tweet_list = @tweet_list.sort { |a,b| b.created_at <=> a.created_at }.first(7)
        self.cache(@sorted_tweet_list, "/shared/widgets/cached/vertical_tweets/", "verticals/#{category.slug}/twitter_feed:#{@twitter_handles}")
      end
      true
    end

    #---------------

    def initialize(screen_name, options={})
      @tweeter     = Tweeter.new("kpccweb")
      @screen_name = screen_name
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

