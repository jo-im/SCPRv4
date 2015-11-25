module Job
  class RetryEmails < Base
    @priority = :mid

    class << self
      def perform
        logger.info "Sending unsent emails to Eloqua. - #{Time.zone.now}"
        unsent_emails = EloquaEmail.unsent
        unsent_emails.each(&:async_send_email)
        logger.info "Finished sending #{unsent_emails.count} unsent emails to Eloqua. - #{Time.zone.now}"
      end
    end
  end
end