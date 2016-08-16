module Concern
  module Callbacks
    module AppleNewsCallback
      extend ActiveSupport::Concern

      included do
        has_one :apple_news_article, as: :record
        after_save :publish_to_apple_news
        after_destroy :delete_from_apple_news
      end

      def to_apple
        {
          version: "1.2",
          identifier: obj_key,
          title: headline,
          subtitle: teaser,
          createdAt: published_at,
          modifiedAt: updated_at,
          language: "en_US",
          layout: {
            columns: 7,
            width: 1024,
            margin: 75,
            gutter: 20
          },
          components: [
            {
              role: "title",
              text: headline,
              textStyle: "title"
            },
            {
              role: "body",
              text: strict_body
            },
            {
              role: "photo",
              :"URL" => asset.full.url
            }
          ],
          documentStyle: {
            backgroundColor: "#F7F7F7"
          },
          componentTextStyles: {
            default: {
              fontName: "Helvetica",
              fontSize: 13,
              linkStyle: {
                textColor: "#428bca"
              }
            },
            title: {
              fontName: "Helvetica-Bold",
              fontSize: 30,
              hyphenation: false
            },
            :"default-body" => {
              fontName: "Helvetica",
              fontSize: 13
            }
          }
        }
      end

      def publish_to_apple_news
        # Only publish our own content
        if ((respond_to?(:source) && source == "kpcc") || true) && (published? || publishing?)
          Job::PublishAppleNewsContent.perform self.class.to_s, self.id, :upsert
        end
      end

      def retrieve_from_apple_news
        Job::PublishAppleNewsContent.get self
      end

      def delete_from_apple_news
        Job::PublishAppleNewsContent.perform self.class.to_s, self.id, :delete
      end

      private

      def strict_body
        # strips out all tags and converts newlines to p tags
        doc = Nokogiri::HTML(body.force_encoding('ASCII-8BIT'))
        doc.xpath('//text()').to_s.split(/\r\n?/).reject(&:empty?).map{|l| "<p>#{l}</p>"}.join('')
      end

    end
  end
end