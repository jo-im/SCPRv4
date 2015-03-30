module AudioSync
  module Pending
    THRESHOLD = 2.weeks

    class << self
      def bulk_sync
        limit = THRESHOLD.ago

        Audio.awaiting.where('created_at > ?', limit).each do |audio|
          begin
            if audio.file.present?
              # Publishing will trigger callbacks.
              audio.publish
            end # W
          rescue => e
            # We don't want to kill the loop, but we do need this error to
            # get to New Relic
            NewRelic::Agent.agent.error_collector.notice_error(e,{
              custom_params: {
                audio_id: audio.id
              }
            })
          end
        end # E
      end # E
    end # E
  end # E
end # !
