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

      def async_notify
        Rails.logger.info "In async_notify for #{ self.obj_key }: Publishing? #{ self.publishing? } | Unpublishing? #{ self.unpublishing? } | Status changed? #{ self.status_changed? } / #{ self.status }"
        if self.publishing?
          Job::PublishNotification.enqueue("Published! <#{self.admin_edit_url}|#{self.to_title}>",self.obj_key)

        elsif self.unpublishing?
          Job::PublishNotification.enqueue("Unpublished: <#{self.admin_edit_url}|#{self.to_title}>",self.obj_key)

        elsif self.status_changed? && self.status != ContentBase::STATUS_DRAFT
          Job::PublishNotification.enqueue("Status Changed to #{self.status_text}: <#{self.admin_edit_url}|#{self.to_title}>",self.obj_key)
        end
      end
    end
  end
end
