require "#{Rails.root}/vendor/lib/apple-news/papi-client/api"
require 'tempfile'
require 'tmpdir'
require 'open-uri'

module Job
  class PublishAppleNewsContent < Base
    @priority = :low
    class << self
      def perform content_type, id, action
        record = content_type.constantize.find(id)
        # The gem provided by Apple expects a JSON file.  Specifically, it wants a file called
        # 'article.json', and refuses any file that has a different name.  Since we don't really
        # want to manage a bunch of JSON files, I've modified the gem to take in a file with any
        # name we specify, but it still tells the API that it's called "article.json" upon request.
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
      def find uuid
        client.get_article uuid
      end
      def get record
        if record.apple_news_article
          find record.apple_news_article.uuid
        end
      end
      def insert record
        open_bundle_for record do |file, dir, record|
          response = client.publish_article({'channel_id' => channel_id, file_name: "article.json"}, dir)
          if response.code == 201
            data = JSON.parse(response.to_s)["data"]
            record.apple_news_article = AppleNewsArticle.create uuid: data["id"], revision: data["revision"]
          end
          response
        end
      end
      def update record
        article = record.apple_news_article
        if article.uuid
          open_bundle_for record do |file, dir, record|
            response = client.update_article(article.uuid, article.revision, {'channel_id' => channel_id, file_name: "article.json", "article_dir" => dir})
            if response.code == 200
              data = JSON.parse(response.to_s)["data"]
              article.update revision: data["revision"]
            end
            response
          end
        else
          nil
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
          response
        else
          nil
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
          return yield f, path, record
        end
      end

      def download_from_to url, dest
        open(dest, 'wb') do |file|
          begin  
            file << open(url).read
          rescue SocketError
            return false
          end
        end        
        true
      end

      def open_bundle_for record, &block
        # This opens a temporary directory for our "bundle",
        # which is where we will include all the files required
        # to publish our article, the most important one being
        # article.json.
        Dir.mktmpdir do |dir|
          doc = record.to_apple
          # thumb_url  = record.try(:asset).try(:small).try(:url)
          # if thumb_url
          # # The thumbnail, unlike images in the article itself,
          # # must be a part of the bundle, so we have to download
          # # it and include it as a file with a specific name.
          #   if download_from_to(thumb_url, "#{dir}/thumbnail.jpg")
          #     doc[:metadata][:thumbnailURL] = "bundle://thumbnail.jpg"
          #   end
          # end
          File.open("#{dir}/article.json", "w") do |f|
            f.write doc.to_json
            f.rewind
            return yield f, dir, record
          end
        end
      end

    end
  end
end