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
            figstring += "<figcaption>#{caption}</figcaption>"
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
      }
    }.freeze

    def call
      map_tags
      # convert_images
      # wrap_images
      doc
    end

  private

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