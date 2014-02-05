# Send batch e-mails.
# Object must respond to `#publish_email`
module Job
  class SendEmailNotification < Base
    @priority = :mid

    class << self
      def perform(klass, id)
        record = klass.constantize.find(id)
        record.publish_email
      end
    end
  end
end
