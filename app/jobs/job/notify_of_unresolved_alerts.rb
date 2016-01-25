module Job
  class NotifyOfUnresolvedAlerts < Base
    @priority = :mid

    class << self
      def perform
        unresolved = BreakingNewsAlert.unresolved
        if unresolved.any?
          config = Rails.configuration.x.api.slack
          slack = Slack::Notifier.new(config['webhook_url'])
          slack.ping "There are Breaking News Alerts that require an end time:\n\n" + unresolved.map(&:admin_edit_url).join("\n")
        end
      end
    end
  end
end