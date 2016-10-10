module Filter
  class AmpFilter < HTML::Pipeline::Filter
    TAG_MAPPINGS = {
      'img' => lambda { |img|
        if img['data-width'] && img['data-height']
          img.name = "amp-img"
          img['layout'] = 'responsive'
          img['srcset'] = img['src']
          img['width']  = img['data-width']
          img['height'] = img['data-height']
          figstring = "<figure>#{img.to_s}"
          if caption = img.attribute('alt') ? img.attribute('alt').value : nil
            figstring += "<figcaption class='media__caption text--light'>#{caption}</figcaption>"
          end
          figstring += "</figure>"
          figure = Nokogiri::HTML::DocumentFragment.parse(figstring).children[0]
          img.replace figure
        else
          img.remove
        end
      },
      'iframe' => lambda { |node|
        node['src'] = node['src'].gsub(%r{^(\/\/|http:\/\/)}, 'https://')
        node['sandbox'] = 'allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox'
        url = URI(node['src'])
        node['layout'] = 'responsive'

        if url.host.include?('youtube.com')
          node.name = 'amp-youtube'
          node['data-videoid'] = node['src'].match(%r{(\/embed\/|watch?v=)(.*)})[2]
          node.remove_attribute('src')
        else
          node.name = 'amp-iframe'
        end
      },
      'script' => lambda { |node|
        # make async
        node['async'] = true
        # protocol-less urls are now an anti-pattern
        # and need to have an explicit protocol
        if node['src'].match(/^\/\//)
          node['src'] = "http:#{node['src']}"
        end
      },
      'a' => lambda { |node|
        # Twitter embeds use script tags, which is not supported
        # by AMP.  Thus, they have to be converted to a custom 
        # tag that can be understood by the Twitter AMP plugin.
        if node['class'] == "embed-placeholder"
          case node['data-service']
          when 'twitter'
            id_matcher = /^(?<url>https?:\/\/twitter\.com\/(?<username>[-a-zA-Z0-9+&@#%?=~_|!:,.;]+)\/status(es){0,1}\/(?<tweetId>\d+)\/{0,1})/i
            if tweetid = (node['href'] || "").match(id_matcher).try(:[], :tweetId)
              node.replace construct_tag %{
                <amp-twitter width=390 height=50
                    layout="responsive"
                    data-tweetid="#{tweetid}">
                </amp-twitter>
              }
            end
          when 'facebook'
            node.replace construct_tag  %{
              <amp-facebook width=390 height=50
                  layout="responsive"
                  data-href="#{node['href']}">
              </amp-facebook>
            }
          when 'youtube'
            id_matcher = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)(?<videoId>[^#\&\?]*).*/
            videoid    = (node['href'] || "").match(id_matcher).try(:[], :videoId)
            node.replace construct_tag  %{
              <amp-youtube width="480" height="270"
                  layout="responsive"
                  data-videoid="#{videoid}">
              </amp-youtube>
            }
          when 'instagram'
            id_matcher = /(?:(?:http|https):\/\/)?(?:www.)?(?:instagram.com|instagr.am)\/p\/(?<shortcode>[A-Za-z0-9-_]+)/i
            shortcode    = (node['href'] || "").match(id_matcher).try(:[], :shortcode)
            node.replace construct_tag  %{
              <amp-instagram
                  data-shortcode="#{shortcode}"
                  width="400"
                  height="400"
                  layout="responsive">
              </amp-instagram>
            }            
          end
        end
      }
    }.freeze

    def call
      map_tags
      # convert_images
      # wrap_images
      doc
    end

  private

    def self.construct_tag html
      Nokogiri::HTML.fragment(html.gsub("\n", "").gsub(/\s+/, " ").strip).children[0]
    end

    def map_tags
      @tags = %w(a em p span h1 h2 h3 h4 h5 h6 div strong s u br blockquote)
      doc.traverse do |node|
        scrub node
      end      
    end
    def scrub node
      if node.name.in?(TAG_MAPPINGS.keys)
        remap node, TAG_MAPPINGS[node.name]
      end
    end
    def remap node, filter
      case filter
      when String
        node.name = filter
      when Proc
        filter.call(node)
      end
    end
  end
end