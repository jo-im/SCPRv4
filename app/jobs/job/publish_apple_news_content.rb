require "#{Rails.root}/vendor/lib/apple-news/papi-client/api"
require 'tempfile'

module Job
  class PublishAppleNewsContent < Base
    @priority = :low
    class << self
      def perform content_type, id, action
        record = content_type.constantize.find(id)
        # The gem provided by Apple expects a JSON file.  Specifically, it wants a file called
        # 'article.json', and refuses any file that has a different name.  Since we don't really
        # want to manage a bunch of JSON files, I've modified the gem to take in a file with any
        # name we give it, but it still tells the API that it's called "article.json" upon request.
        if action == :upsert
          unless record.apple_news_article
            insert record
          else
            update record
          end
        elsif action == :delete
          delete record
        end
      rescue => e
        NewRelic.log_error(e)
      end
      private
      def insert record
        open_json_file_for record do |file, path, record|
          response = client.publish_article({'channel_id' => channel_id, file_name: path.basename.to_s}, path.dirname.to_s)
          if response.code == 201
            data = JSON.parse(response.to_s)["data"]
            record.apple_news_article = AppleNewsArticle.create uuid: data["id"], revision: data["revision"]
          end
        end
      end
      def update record
        article = record.apple_news_article
        if article.uuid
          open_json_file_for record do |file, path, record|
            response = client.update_article(article.uuid, article.revision, {'channel_id' => channel_id, file_name: path.basename.to_s, "article_dir" => path.dirname.to_s})
            if response.code == 200
              data = JSON.parse(response.to_s)["data"]
              article.update revision: data["revision"]
            end
          end
        end
      end
      def delete record
        article = record.apple_news_article
        uuid = article.try(:uuid)
        if uuid
          response = client.delete_article uuid
          if response.code == 204
            article.destroy
          end
        end
      end
      def client
        PapiClient::API.new(
          endpoint: Rails.application.secrets.api["apple_news"]["endpoint"], 
          key: Rails.application.secrets.api["apple_news"]["key_id"], 
          secret: Rails.application.secrets.api["apple_news"]["secret"]
        )
      end
      def channel_id
        Rails.application.secrets.api["apple_news"]["channels"]["kpcc"]["id"]
      end
      def open_json_file_for record, &block
        Tempfile.open ['article', '.json'] do |f|
          f.write record.to_apple.to_json
          f.rewind
          path      = Pathname.new(f.path)
          yield f, path, record
        end
      end
    end
  end
end