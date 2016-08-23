require 'reverse_markdown'
require 'htmlentities'
require 'digest'
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

      def elements_to_components html
        processed_html = preprocess(html) # Mostly insert inline assets
        Nokogiri::HTML::DocumentFragment.parse(processed_html).children.to_a.map do |element|
          element_to_component element
        end.flatten # we expect components to always come in as arrays, as some of them
        # realistically require two elements(e.g. a figure needs a separate caption element)
      end

      def element_to_component element
        if element.name == 'img'
          img_to_figure_component element
        else
          element_to_body_component element
        end
      end

      def img_to_figure_component element
        [
          {
            role: "figure",
            :"URL" => element['src'],
            caption: (element['alt'] || element['title']),
            identifier: 'inline-asset'
          },
          {
            role: "caption",
            text: (element['alt'] || element['title']),
            textStyle: "figcaptionStyle",
          }   
        ]
      end

      def element_to_body_component element
        markup   = element.to_s
        markdown = html_to_markdown(markup)
        output = []
        unless markdown.blank?
          output << {
            role: "body",
            text: markdown,
            layout: "bodyLayout",
            textStyle: "bodyStyle",
            format: "markdown"
          }
        end
        output
      end

      def html_to_markdown html
        HTMLEntities.new.decode ReverseMarkdown.convert html, unknown_tags: :drop
      end

      def preprocess html
        insert_inline_assets html
      end

      def insert_inline_assets html
        process_markup html, 'img.inline-asset[data-asset-id]' do |element|
          asset = assets.find_by asset_id: element['data-asset-id']
          if asset && asset.owner.try(:include?, "KPCC")
            element['src'] = asset.full.url
            element['alt'] = asset.caption
          else
            element.remove
          end
        end
      end

      def process_markup html, selector, &block
        doc = Nokogiri::HTML(html.force_encoding('ASCII-8BIT'))
        doc.css(selector).each{|element|
          yield element
        }
        doc.css('body').children.to_s.html_safe
      end

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