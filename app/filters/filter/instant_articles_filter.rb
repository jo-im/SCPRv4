module Filter
  class InstantArticlesFilter < HTML::Pipeline::Filter
    def call
      wrap_embeds
      wrap_iframes
      translate_headings
      doc
    end

    private

    def wrap_iframes
      # Iframes should be embedded in a figure tag with op-interactive class.
      # This will take care of our dynamic embeds as well as iframes inserted
      # by the author.
      doc.search('iframe') do |iframe|
        figure = Nokogiri::HTML::DocumentFragment.parse("<figure class='op-interactive'>#{iframe.to_s}</figure>").children[0]
        iframe.replace figure
      end
    end

    def translate_headings
      # For whatever reason, Facebook only allows h1 and h2 tags.
      # H3 is reserved for "kickers", but it's unclear why others
      # are not permitted.  
      # While they will automatically translate h(n>2) tags to
      # h2, a warning is still displayed next to each story.
      # We will translate the tags here to prevent that warning.
      doc.search("h1, h2, h3, h4, h5, h6").each do |heading|
        heading.inner_html = heading.text # Headings shouldn't contain other tags.
        unless ['h1', 'h2'].include?(heading.name.downcase)
          heading.name = "em"
        end
      end
    end

    def wrap_embeds
      # Passes the HTML through an instance of Embeditor running in Node.js
      doc.search('.embed-wrapper').each do |embed|
        # This will later be wrapped in an op-interactive figure along with any other iframes.
        figure = Nokogiri::HTML::DocumentFragment.parse("<iframe class='column-width'>#{embed.to_s}</iframe>").children[0]
        embed.replace figure
      end
    end
  end
end