# PublishNotificationCallback
#
# Sends publish notifications to anywhere.
# Configure where it gets sent in the PublishNotification job.
#
# Requires StatusBuilder methods.
module Concern
  module Callbacks
    module PublishNotificationCallback
      extend ActiveSupport::Concern

      included do
        after_save :async_notify
      end

      # This a feature that the editors came to depend on - notifications
      # about article state in their Campfire room. Eventually this could be
      # replaced with something built-in to Outpost (a notification system
      # via Newsroom), but for now if it goes away they will ask for it back.
      def async_notify
        if self.publishing?
          Job::PublishNotification.enqueue(
            "Published! #{self.to_title} (#{self.admin_edit_url})",
            "daily_web")

        elsif self.unpublishing?
          Job::PublishNotification.enqueue(
            "Unpublished: #{self.to_title} (#{self.admin_edit_url})",
            "daily_web")

        elsif self.status_changed?
          Job::PublishNotification.enqueue(
            "Status Changed to #{self.status_text}: " \
            "#{self.to_title} (#{self.admin_edit_url})",
            "daily_web")x
        end
      end
    end
  end
end
