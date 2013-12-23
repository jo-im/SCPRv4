module AudioSync
  module Pending
    THRESHOLD = 2.weeks

    class << self
      def bulk_sync
        time_limit = THRESHOLD.ago

        Audio.awaiting.where('created_at > ?', time_limit).each do |audio|
          if audio.file.present?
            # Publishing will trigger the file info job.
            audio.publish
          end # W
        end # E
      end # E
    end # E
  end # E
end # !
