##
# Send batch e-mails.
# The passed-in object just needs to response to `#publish_email`
#
module Job
  class BatchEmail < Base
    @queue = "#{namespace}:batch_email"

    class << self
      def perform(klass, id)
        record = klass.constantize.find(id)
        record.publish_email
      end
    end
  end
end
