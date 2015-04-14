module Job
  class PublishNotification < Base
    @priority = :low

    class << self
      def perform(message,obj_key=nil)
        config = Rails.application.config.api['slack']

        self.log "PublishNotification: #{obj_key} | #{message}"

        if Rails.env == "development"
          message = "(TESTING) #{message}"
        end

        attachment = nil
        if obj_key
          obj = ContentBase.safe_obj_by_key(obj_key)

          if obj
            attachment = {
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

          resp = slack.ping message, attachments:[attachment]


          if resp.code != "200"
            Rails.logger.info "PublishNotification: Initial attempt failed for #{message}"

            # FIXME: This is a temporary fix to try and understand an issue we're tracking
            # in SCPRv4#239
            raise "Non-200 response from Slack"
          else
            Rails.logger.info "Successful publish for #{message}"
          end
        else
          Rails.logger.info "PublishNotification: #{message}"
        end
      end
    end
  end
end
