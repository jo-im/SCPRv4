require 'rss'

module Job
  class FetchMarketplaceArticles < Base
    @priority = :low

    RSS_URL   = "http://www.marketplace.org/latest-stories/long-feed.xml"
    LIMIT     = 4

    class << self
      def perform
        feed = RSS::Parser.parse(RSS_URL, false)

        if !feed || feed.items.empty?
          log "Feed is empty. Aborting."
          return false
        end

        log "#{feed.items.size} marketplace stories found."

        latest_articles = feed.items.first(LIMIT)

        self.cache(latest_articles,
          "/shared/widgets/cached/marketplace",
          "views/business/marketplace",
          local: :articles
        )

        # Should we break the Business vertical cache here?
        # It's probably not worth it - there's enough other stuff
        # breaking that cache and this is of relatively low importance.
      end
    end
  end # FetchMarketplaceArticles
end # Job
