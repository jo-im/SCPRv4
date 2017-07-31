# Cache the homepage sections.
module Job
  class BetterHomepageCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        homepage  = ::BetterHomepage.current.last
        cache_articles homepage
        cache_contents homepage
        cache_right_asides homepage
      end
    private
      def cache_articles homepage
        Rails.cache.write "homepage/articles", homepage.content_articles
      end
      def cache_contents homepage
        @homepage = homepage
        return if !homepage
        key       = "better_homepage/contents"
        cacher.rendering_controller.instance_variable_set(:@homepage, homepage)
        cached    = cacher.render partial: key
        cacher.send :write, key, cached
      end
      def cache_right_asides homepage
        @homepage = homepage
        return if !homepage
        key       = "better_homepage/right_asides"
        cacher.rendering_controller.instance_variable_set(:@homepage, homepage)
        cached    = cacher.render partial: key
        cacher.send :write, key, cached        
      end
    end
  end
end
