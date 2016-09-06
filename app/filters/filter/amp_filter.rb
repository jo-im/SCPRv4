module Filter
  class AmpFilter < HTML::Pipeline::Filter
    TAG_MAPPINGS = {
      'img' => lambda { |node|
        if node['width'] && node['height']
          node.name = 'amp-img'
          node['layout'] = 'responsive'
          node['srcset'] = node['src']
        else
          node.remove
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
      @tags = %w(a em p span h1 h2 h3 h4 h5 h6 div strong s u br blockquote)
      doc.traverse do |node|
        scrub node
      end
      doc
    end

  private
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