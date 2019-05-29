##
# SyncRemoteArticles
#
# Sync with the Remote Article API's
# This isn't on the "rake_tasks" queue because it
# can be triggered from the CMS.
module Job
  class SyncRemoteArticles < Base
    @priority = :mid

    class << self
      def perform
        @synced = RemoteArticle.sync
        self.log "Synced Remote Articles."
      end

      def on_failure(error)
        return
      end
    end
  end
end
