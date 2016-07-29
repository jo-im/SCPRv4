module Concern
  module Callbacks
    module ExpireIngestFeedCacheCallback
      extend ActiveSupport::Concern

      # Here, we are assuming that if an article is published,
      # it will effect the list of articles in the Facebook 
      # and Apple ingest RSS feeds.  Since the controller that
      # handles those feeds uses caching due to the slow performance
      # of the queries, we need to clear that cache upon an 
      # article being published.

      included do
        after_save :expire_ingest_feed_cache, if: ->{(published? || publishing?) && changed?}
      end

      private

      def expire_ingest_feed_cache
        Rails.cache.delete "controller/ingest-feed-controller"
      end

    end
  end
end