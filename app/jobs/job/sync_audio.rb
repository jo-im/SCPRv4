##
# Job::SyncAudio
module Job
  class SyncAudio < Base
    @priority = :low

    class << self
      def perform(*klasses)
        klasses.each { |k| k.constantize.bulk_sync }
      end
    end # singleton
  end # SyncAudio
end # Job
