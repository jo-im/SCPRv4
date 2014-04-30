require 'rss'

module Job
  class FetchMarketplaceArticles < Base
    @priority = :low

    RSS_URL   = "http://www.marketplace.org/latest-stories/long-feed.xml"
    LIMIT     = 2

    class << self
      def perform
        feed = RSS::Parser.parse(RSS_URL, false)

        log "#{feed.items.size} marketplace stories found"

        if !feed || feed.items.empty?
          log "Feed is empty. Aborting."
          return false
        end

        latest_articles = feed.items.first(LIMIT)
        Rails.cache.write("business/marketplace", latest_articles)

        self.cache(latest_articles,
          "/shared/widgets/cached/marketplace",
          "views/business/marketplace",
          local: :articles
        )

        latest_articles.each do |article|
          log "Wrote Marketplace Story #{article.link} to the cache"
        end
      end
    end
  end # FetchMarketplaceArticles
end # Job
