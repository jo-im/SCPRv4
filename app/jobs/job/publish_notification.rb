module Job
  class PublishNotification < Base
    @priority = :low

    class << self
      def perform(message,obj_key)
        config = Rails.application.config.api['slack']

        if Rails.env == "development"
          message = "(TESTING) #{message}"
        end

        attachment = nil
        if obj_key
          obj = ContentBase.safe_obj_by_key(obj_key)

          if obj
            attachment = {
              pretext: message,
              fields: [],
            }

            # content type
            attachment[:fields].push({
              title: "Type",
              value: obj.class.name,
              short: true,
            })

            attachment[:fields].push({
              title: "Byline",
              value: obj.byline,
              short: true,
            })

            # Live link if published
            if obj.published?
              attachment[:fields].push({
                title: "Live URL",
                value: "<#{obj.public_url}>",
                short: false
              })
            end
          end


        end

        if config && config['webhook_url']
          slack = Slack::Notifier.new(config['webhook_url'])

          slack.ping message, attachments:[attachment]
        else
          Rails.logger.info "PublishNotification: #{message}"
        end
      end
    end
  end
end
