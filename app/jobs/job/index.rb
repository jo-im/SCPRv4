##
# Index
#
# Perform sphinx indexing asynchronously
#
module Job
  class Index < Base
    class << self
      def queue; QUEUES[:sphinx]; end

      def perform(models)
        Indexer.new(*models.map(&:constantize)).index
        self.log "Successfully indexed: #{models.present? ? models : "all"}"
      end
    end
  end
end
