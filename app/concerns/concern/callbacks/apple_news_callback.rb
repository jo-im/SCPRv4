module Concern
  module Callbacks
    module AppleNewsCallback
      extend ActiveSupport::Concern

      included do
        has_one :apple_news_article, as: :record
        after_save :async_publish_to_apple_news
        after_destroy :async_delete_from_apple_news
      end

      def to_apple
        {
          version: "1.0",
          identifier: obj_key,
          title: headline,
          language: "en",
          layout: {
            columns: 7,
            width: 1024,
            margin: 70,
            gutter: 40
          },
          subtitle: teaser,
          metadata: {
            excerpt: teaser,
            thumbnailURL: asset.full.url
          },
          documentStyle: {
            backgroundColor: "#f6f6f6"
          },
          components: to_components,
          componentTextStyles: {
            titleStyle: {
              textAlignment: "left",
              fontName: "Georgia-Bold",
              fontSize: 44,
              lineHeight: 54,
              textAlignment: "center",
              textColor: "#212121"
            },
            figcaptionStyle: {
              textAlignment: "left",
              fontName: "AvenirNext-Regular",
              fontSize: 16,
              textColor: "#a6a6a6"
            },
            introStyle: {
              textAlignment: "left",
              fontName: "AvenirNext-Regular",
              fontSize: 15,
              textColor: "#363636"
            },
            authorStyle: {
              textAlignment: "left",
              fontName: "AvenirNext-Regular",
              fontSize: 14,
              textColor: "#a6a6a6"
            },
            bodyStyle: {
              textAlignment: "left",
              fontName: "Georgia",
              fontSize: 18,
              lineHeight: 26,
              textColor: "#313131",
              linkStyle: {
                textColor: "#31aad3"
              },
            }
          },
          componentLayouts: {
            headerImageLayout: {
              columnStart: 0,
              columnSpan: 7,
              ignoreDocumentMargin: true,
              minimumHeight: "40vh",
              margin: {
                top: 15,
                bottom: 15
              }
            },
            titleLayout: {
              columnStart: 0,
              columnSpan: 7,
              margin: {
                top: 50,
                bottom: 10
              }
            },
            # introLayout: {
            #   columnStart: 0,
            #   columnSpan: 7,
            #   margin: {
            #     top: 15,
            #     bottom: 15
            #   }
            # },
            authorLayout: {
              columnStart: 0,
              columnSpan: 7,
              margin: {
                top: 15,
                bottom: 15
              }
            },
            bodyLayout: {
              columnStart: 0,
              columnSpan: 7,
              margin: {
                top: 15,
                bottom: 15
              }
            }
          }
        }
      end

      def async_publish_to_apple_news
        Job::PublishAppleNewsContent.enqueue self.class.to_s, self.id, "upsert"
      end

      def async_delete_from_apple_news
        Job::PublishAppleNewsContent.enqueue self.class.to_s, self.id, "delete"
      end

      def publish_to_apple_news
        apple_news_api_call "upsert"
      end

      def delete_from_apple_news
        apple_news_api_call "delete"
      end

      def apple_news_api_call action
        return false if (action == "upsert") && !should_publish_to_apple_news?
        publisher = AppleNews::Publisher.new(self)
        publisher.perform action
      end

      def should_publish_to_apple_news?
        if respond_to?(:source)
          # is it one of our own stories and is it published?  and is it a recent story?
          (source == "kpcc") && (published? || publishing?) && (published_at > 48.hours.ago) 
        else
          true # assume that no source means that it's our own content
        end
      end

      def retrieve_from_apple_news
        publisher = AppleNews::Publisher.new(self)
        publisher.get self
      end

      private

      include AppleNews

      def to_components
        [
          {
            role: "title",
            layout: "titleLayout",
            text: headline,
            textStyle: "titleStyle"
          },
          # {
          #   role: "intro",
          #   layout: "introLayout",
          #   text: teaser,
          #   textStyle: "introStyle"
          # },
          {
            role: "header",
            layout: "headerImageLayout",
            style: {
              fill: {
                type: "image",
                :"URL" => asset.full.url,
                fillMode: "cover",
                verticalAlignment: "center"
              }
            }
          },
          {
            role: "author",
            layout: "authorLayout",
            text: byline,
            textStyle: "authorStyle"
          }
        ].concat(elements_to_components(body)).compact
      end

    end
  end
end