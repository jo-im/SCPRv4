##
# Job::SyncAudio
module Job
  class SyncAudio < Base
    @queue = "#{namespace}:sync_audio"

    class << self
      def perform(*klasses)
        klasses.each { |k| k.constantize.bulk_sync }
      end
    end # singleton
  end # SyncAudio
end # Job
