module Concern
  module Callbacks
    module GrandCentralCallback
      extend ActiveSupport::Concern

      included do
        after_create  -> () { grand_central_request(:post) },   if: -> () { published? || publishing? }
        after_update  -> () { grand_central_request(:put) },    if: -> () { published? }
        after_update  -> () { grand_central_request(:delete) }, if: -> () { changes['status'] == 5 }
        after_destroy -> () { grand_central_request(:delete) }, if: -> () { published? }
      end

      private

      def to_grand_central_article
        to_article.try(:to_grand_central_article)
      end

      def grand_central_request method_name
        return [] if respond_to?(:source) && source != "kpcc"
        if Rails.env == "production" || Rails.env == "staging"
          sqs = Aws::SQS::Client.new({
            region: "us-west-1",
            credentials: Aws::Credentials.new(Rails.application.secrets.grand_central["access_key_id"], Rails.application.secrets.grand_central["secret_access_key"])
          });

          message_body     = to_grand_central_article

          facebook_message = grand_central_message(adapter_name: 'facebook', method_name: method_name, channel: Rails.application.secrets.api["instant_articles"]["channels"]["kpcc"]["id"])

          [sqs.send_message(facebook_message)]
        else
          []
        end
      rescue => err
        NewRelic.log_error(err)
      end

      def grand_central_message adapter_name:"", method_name:"", channel:""
        message = {
          message_attributes: {
            _id: {
              data_type: "String",
              string_value: obj_key
            },
            publisher: {
              data_type: "String",
              string_value: "scprv4"
            },
            adapter: {
              data_type: "String",
              string_value: adapter_name
            },
            method: {
              data_type: "String",
              string_value: method_name
            },
            channel: {
              data_type: "String",
              string_value: "#{channel}"
            },
            castType: {
              data_type: "String",
              string_value: obj_key.split("-")[0].gsub("_", "-")
            }
          },
          message_body: to_grand_central_article,
          queue_url: Rails.application.secrets.grand_central["queue_url"]
        }
      end

    end
  end
end