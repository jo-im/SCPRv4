# See the Twitter API docs for more available options:
# https://dev.twitter.com/docs/api/1/get/statuses/user_timeline

module Job
  class VerticalsTwitterCache < Base
    @queue = "#{namespace}:rake_tasks"

    class << self
      def perform
        Category.where(is_active: true).each do |category|
          tweet_list = []

          category.bios.map(&:twitter_handle).each do |handle|
            task = Job::TwitterCache.new(handle)

            if tweets = task.fetch
              tweet_list += tweets
            end
          end

          tweets = tweet_list.sort { |a,b| b.created_at <=> a.created_at }

          self.cache(
            tweets.first(7),
            "/shared/widgets/cached/vertical_tweets",
            "verticals/#{category.slug}/twitter_feed"
          )

          # Refresh the cache on the vertical page
          # so the new tweets show up.
          category.touch
        end

        true
      end
    end
  end # VerticalsTwitterCache
end # Job
