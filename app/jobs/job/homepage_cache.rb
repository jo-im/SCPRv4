# Cache the homepage sections.
module Job
  class HomepageCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        homepage = ::Homepage.published.first
        return if !homepage

        previews = homepage.category_previews
        self.cache(previews, "/home/cached/sections", "home/sections")
      end
    end
  end
end
