module Job
  class PublishNotification < Base
    @priority = :low

    class << self
      def perform(message)
        config = Rails.application.config.api['slack']

        if config && config['webhook_url']
          slack = Slack::Notifier.new(config['webhook_url'])
          slack.ping message
        else
          Rails.logger.info "PublishNotification: #{message}"
        end
      end
    end
  end
end
