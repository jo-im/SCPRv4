# Cache the homepage sections.
module Job
  class HomepageCache < Base
    class << self
      # This job needs to be on the sphinx queue so
      # that it runs *after* a sphinx index has
      # occurred, because the homepage caching relies
      # on an up-to-date index.
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
