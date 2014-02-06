##
# Job::SyncAudio
module Job
  class SyncAudio < Base
    @priority = :low

    class << self
      def perform(klass)
        klass.constantize.bulk_sync
      end
    end # singleton
  end # SyncAudio
end # Job
