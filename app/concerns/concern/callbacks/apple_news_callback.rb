require 'reverse_markdown'
require 'htmlentities'
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
            thumbnailURL: asset.asset.thumb.url
          },
          documentStyle: {
            backgroundColor: "#f6f6f6"
          },
          components: [
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
            },
            {
              role: "body",
              text: markdown_body,
              layout: "bodyLayout",
              textStyle: "bodyStyle",
              format: "markdown"
            }
          ],
          componentTextStyles: {
            titleStyle: {
              textAlignment: "left",
              fontName: "Georgia-Bold",
              fontSize: 44,
              lineHeight: 54,
              textAlignment: "center",
              textColor: "#212121"
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

      def markdown_body
        # Apple News format does support inline styling, but this is done by creating
        # ranges and adding it to a list of inlineTextStyles.  Unfortunately, Apple News
        # does not support HTML, and it would be a shame to expend effort on a parser
        # for this one task.  However, Apple News does support Markdown, and converting
        # HTML to Markdown is fairly trivial.
        HTMLEntities.new.decode ReverseMarkdown.convert Nokogiri::HTML::DocumentFragment.parse(body).to_s, unknown_tags: :drop
      end

      def text_body
        Nokogiri::HTML::DocumentFragment.parse(Nokogiri::HTML(body.force_encoding('ASCII-8BIT')).xpath('//text()').to_s)
          .to_s
          .split(/\r\n?/)
          .join("\n")
      end

      def strict_body
        # strips out all tags and converts newlines to p tags
        doc = Nokogiri::HTML(body.force_encoding('ASCII-8BIT'))
        doc.xpath('//text()').to_s.split(/\r\n?/).reject(&:empty?).map{|l| "<p>#{l}</p>"}.join('')
      end

    end
  end
end