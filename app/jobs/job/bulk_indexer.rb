module Job
  class BulkIndexer < Base
    include Resque::Plugins::UniqueJob
    @priority = :low

    class << self
      def perform(body)
        ES_CLIENT.bulk body: body
      end
    end
  end
end