# Cache the homepage sections.
module Job
  class BetterHomepageCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        homepage = ::BetterHomepage.current.last
        return if !homepage

        content  = homepage.content

        self.cache(content, "better_homepage/contents", "better_homepage/contents")
        self.cache(homepage.check_it_out, "layouts/better_homepage/check_it_out", "layouts/better_homepage/check_it_out")
      end
    end
  end
end
