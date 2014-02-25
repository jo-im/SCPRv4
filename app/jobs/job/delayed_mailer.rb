module Job
  class DelayedMailer < Base
    # These don't need to be sent out immediately
    @priority = :low

    class << self
      def perform(mailer_class, method, args)
        log "Sending email: #{mailer_class}, #{method}, #{args.inspect}"
        mailer = mailer_class.constantize
        mailer.send(method, *args).deliver
      end
    end
  end
end
