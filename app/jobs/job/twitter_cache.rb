# See the Twitter API docs for more available options:
# https://dev.twitter.com/docs/api/1/get/statuses/user_timeline

module Job
  class TwitterCache < Base
    @priority = :low

    FEEDS = [
      {
        screenname: "KPCCForum",
        partial:    "/shared/widgets/cached/tweets",
        cache_key:  "twitter:KPCCForum",
      },
      {
        screenname: "kpcc",
        partial:    "/shared/widgets/cached/sidebar_tweets",
        cache_key:  "twitter:kpcc",
        options:    { count: 4 }
      }
    ]

    DEFAULTS = {
      :count            => 6,
      :trim_user        => false,
      :include_rts      => true,
      :exclude_replies  => true,
      :include_entities => false
    }

    class << self
      def perform
        # -- Process normal accounts -- #

        FEEDS.each do |f|
          options = (f[:options]||{}).reverse_merge(DEFAULTS)
          job = new(f[:screenname])

          puts "Calling fetch with #{ options }"
          tweets = job.fetch(options)

          if tweets && tweets.present?
            self.cache(tweets,f[:partial],f[:cache_key])
          end
        end

        # -- Vertical Reporter Accounts -- #

        Vertical.all.each do |vertical|
          vtweets = []

          vertical.reporters.select { |b| b.twitter_handle.present? }.each do |bio|
            job = new(bio.twitter_handle)
            vtweets += job.fetch||[]
          end

          vtweets.sort! { |a,b| b.created_at <=> a.created_at }

          self.cache(
            vtweets.first(7),
            "/shared/widgets/cached/vertical_tweets",
            "verticals/#{vertical.slug}/twitter_feed"
          )

          vertical.touch()
        end
      end
    end

    #----------

    def initialize(screen_name)
      @tweeter      = Tweeter.new("kpccweb")
      @screen_name  = screen_name
    end

    def fetch(options={})
      twitter_options = options.dup

      if twitter_options[:exclude_replies] && twitter_options[:count]
        # According to the Twitter documentation, if you specify a count
        # and exclude replies, your results will `count - replies` in length.
        # To get around this, we'll grab 10 times as many tweets as
        # we actually need, and hopefully that will cover us.
        # Another option would be to hit the API until we have the correct
        # number of tweets, but since twitter doesn't do proper pagination
        # it's more complicated than it's worth. The max_id would be an
        # unreliable parameter to use, since it would only include "real"
        # tweets.
        twitter_options[:count] = twitter_options[:count] * 10
      end

      begin
        self.log  "Fetching tweets for #{@screen_name}..."

        # We only want to return the requested count here, even though we
        # may actually be fetching way more.
        tweets = @tweeter.user_timeline(@screen_name, twitter_options)
        options[:count] ? tweets.first(options[:count]) : tweets
      rescue Twitter::Error::NotFound => e
        NewRelic.log_error(e)
        warn "Error caught in TwitterCache#fetch: #{e}"
        self.log "Error: \n #{e}"
        false
      end
    end

    add_transaction_tracer :fetch, category: :task
  end # TwitterCache
end # Job
