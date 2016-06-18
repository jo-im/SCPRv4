# Cache the homepage sections.
module Job
  class BetterHomepageCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        homepage = ::BetterHomepage.published.first
        return if !homepage

        content  = homepage.content
        self.cache(content, "better_homepage/contents", "better_homepage/index")
      end
    end
  end
end
