# Beat an object to a pulp until it can fit into the Eloqua API,
# then forward it to our loyal subscribers.
#
# Note that this module does *not* include the ActiveRecord callbacks for
# firing the e-mail.
#
# Your class must implement:
# * `as_eloqua_email`
# * `should_send_email?`
# * `update_email_status`
#
# The schema for this class must include:
# * email_sent (Boolean)
#
# You must also add an Eloqua configuration for the class with the key being
# the underscored class name. See the documentation for `::eloqua_config` for
# more details.
#
module Concern
  module Methods
    module EloquaSendable
      extend ActiveSupport::Concern
      include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation


      # Enqueue a background task to publish the e-mail.
      #
      # Returns nothing.
      def async_send_email
        Resque.enqueue(Job::SendEmailNotification, self.class.name, self.id)
      end

      # Returns the name of the class for the instance as a string.
      def obj_name
        self.class.name
      end

      # Publish an e-mail for this object to the Eloqua API.
      #
      # Returns nothing.
      def publish_email(options={})
        return if !should_send_email?

        config = eloqua_config

        email_object  = self.as_eloqua_email

        # Create the e-mail.
        email = Eloqua::Email.create(
          :folderId            => config['email_folder_id'],
          :emailGroupId        => config['email_group_id'],
          :senderName          => "89.3 KPCC",
          :senderEmail         => email_object[:email],
          :replyToName         => "89.3 KPCC",
          :replyToEmail        => email_object[:email],
          :isTracked           => true,
          :name                => email_object[:name],
          :description         => email_object[:description],
          :subject             => email_object[:subject],
          :isPlainTextEditable => true,
          :plainText           => email_object[:plain_text_body],

          :htmlContent => {
            :type => "RawHtmlContent",
            :html => email_object[:html_body]
          }
        )

        # Create the Campaign, passing in the
        # ID for the e-mail we just created, as well as the
        # application-configured segment ID.
        campaign = Eloqua::Campaign.create(
          {
            :folderId    => config['campaign_folder_id'],
            :name        => email_object[:name],
            :description => email_object[:description],
            :startAt     => Time.zone.now.yesterday.to_i,
            :endAt       => Time.zone.now.tomorrow.to_i,
            :elements    => [
              {
                :type      => "CampaignSegment",
                :id        => "-980",
                :name      => "Segment Members",
                :segmentId => config['segment_id'],
                :position  => {
                  :type => "Position",
                  :x    => 17,
                  :y    => 14
                },
                :outputTerminals => [
                  {
                    :type          => "CampaignOutputTerminal",
                    :id            => "-981",
                    :connectedId   => "-990",
                    :connectedType => "CampaignEmail",
                    :terminalType  => "out"
                  }
                ]
              },
              {
                :type           => "CampaignEmail",
                :id             => "-990",
                :emailId        => email.id,
                :name           => "E-mail",
                :sendTimePeriod => "sendAllEmailAtOnce",
                :position       => {
                  :type => "Position",
                  :x    => 17,
                  :y    => 120
                },
              }
            ]
          }
        )

        update_email_status(campaign)
      end

      add_transaction_tracer :publish_email, category: :task


      # This object as an eloqua e-mail.
      #
      # Must contain the following keys:
      # * :html_body - (String) The HTML form of the e-mail body.
      # * :plain_text_body - (String) The plaintext form of the e-mail body.
      # * :name - (String) Internal name for this email (for Eloqua lists).
      # * :description - (String) Internal description for this Email.
      # * :subject - (String] The subject of the e-mail.
      #
      # Returns Hash.
      def as_eloqua_email
        raise NotImplementedError
      end

      # Get the Eloqua configuration from the underscored class name.
      # Raises an error if the configuration isn't found.
      #
      # This will look an eloqua configuration that matches the underscored
      # class name, eg `breaking_news_alert`.
      # For example, for BreakingNewsAlert:
      #
      # eloqua:
      #   attributes:
      #     breaking_news_alert:
      #       email_group_id: xx
      #       segment_id: xxx
      #       campaign_folder_id: xxxx
      #       email_folder_id: xxxx
      #
      # See config/templates/api_config.yml.ci for an example.
      #
      # If the key you want to use doesn't match the class name, just
      # override this method.
      #
      # Returns Hash of Strings
      def eloqua_config config=nil
        attributes = config || Rails.configuration.x.api.eloqua.attributes
        (self.obj_name ? attributes[self.obj_name.underscore] : nil) || raise_missing_eloqua_config(obj_name)
      end


      private

      # Update the email_sent status for this object.
      # Returns boolean.
      def update_email_status(campaign)
        raise NotImplementedError
      end

      # Whether or not to create the data in Eloqua.
      # Returns boolean.
      def should_send_email?
        raise NotImplementedError
      end


      # Controller for rendering templates into strings that
      # we can send to the API.
      def view
        @view ||= CacheController.new
      end

      def raise_missing_eloqua_config name
        raise "No Eloqua Configuration found for #{name}. " \
              "Is your api_config.yml up to date?"
      end

    end
  end
end
