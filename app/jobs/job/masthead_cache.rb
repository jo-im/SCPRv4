# Cache latest news and blogs for the masthead
module Job
  class MastheadCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        news = ApplicationController.helpers.latest_news()
        blog_entries = ApplicationController.helpers.latest_blogs()

        if news.any?
          self.cache(news,"/shared/masthead/featured","masthead-latest-news", local:"articles")
        end

        if blog_entries.any?
          self.cache(blog_entries,"/shared/masthead/from_our_blogs","masthead-latest-blogs", local:"entries")
        end
      end
    end
  end
end
