##
# Send a breaking news alert
#
module Job
  class SendShortListEmail < Base
    @queue = "#{namespace}:short_list_email"

    class << self
      def perform(id)
        @edition = Edition.find(id)
        @edition.publish_email
      end
    end
  end
end

