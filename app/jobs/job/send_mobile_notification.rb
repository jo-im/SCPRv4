# Send a mobile notification
# Object must respond to `#publish_mobile_notification`
module Job
  class SendMobileNotification < Base
    @priority = :mid

    class << self
      def perform(klass, id)
        record = klass.constantize.find(id)
        record.publish_mobile_notification
      end
    end
  end
end
