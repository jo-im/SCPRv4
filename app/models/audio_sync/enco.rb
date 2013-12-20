#
# EncoAudio
#
# Given enco_number and enco_date
#
module AudioSync
  class Enco < Base
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
    logs_as_task

    STORE_DIR       = "features"
    SYNC_THRESHOLD  = 2.weeks


    class << self
      # This method is used by Job::SyncAudio
      def bulk_sync
        limit     = SYNC_THRESHOLD.ago
        awaiting  = self.awaiting_audio.where("created_at > ?", limit)
        awaiting.each(&:sync)
      end
    end # singleton


    # Find the URL for the given information.
    #
    # Returns String
    def set_url
      date = audio.enco_date.strftime("%Y%m%d")
      filename = "#{date}_features#{audio.enco_number}.mp3"

      audio.url = Audio.url("features", filename)
    end
  end
end
