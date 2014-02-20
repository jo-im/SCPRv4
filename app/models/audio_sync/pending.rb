module AudioSync
  module Pending
    THRESHOLD = 2.weeks

    class << self
      def bulk_sync
        limit = THRESHOLD.ago

        Audio.awaiting.where('created_at > ?', limit).each do |audio|
          if audio.file.present?
            # Publishing will trigger callbacks.
            audio.publish
          end # W
        end # E
      end # E
    end # E
  end # E
end # !
