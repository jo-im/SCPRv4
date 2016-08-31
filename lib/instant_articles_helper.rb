module InstantArticlesHelper

  def render_asset(content, options={})
    asset = options[:asset] || nil
    # return if options[:kpcc_only] && asset && !asset.owner.try(:include?, "KPCC")
    if options[:asset_display]
      asset_display = options[:asset_display]
    else 
      asset_display = 'default'
    end
    render partial: "feeds/shared/instant_articles/#{asset_display}", locals: {content: content, asset: asset}
  end

  def render_lead_asset content
    path = Rails.root.join('app', 'views', 'feeds', 'shared', 'instant_articles')
    if Dir.glob("#{path}/*").join("").include?(content.feature.try(:asset_display) || 'NO_ASSET')
      asset_display = content.feature.try(:asset_display)
    else 
      asset_display = 'default'
    end
    render_asset content, asset_display: asset_display
  end

  def render_body content
    # This contains the pipeline for filtering
    # the HTML body of the article.
    translate_headings strip_comments remove_empty_paragraphs wrap_iframes process_embeds insert_inline_assets content
  end

  def process_embeds body
    # Passes the HTML through an instance of Embeditor running in Node.js
    if @embeditor
      html = @embeditor.process body
      @embeditor.reload
      process_markup html, '.embed-wrapper' do |embed, doc|
        # This will later be wrapped in an op-interactive figure along with any other iframes.
        figure = Nokogiri::HTML::DocumentFragment.parse("<iframe class='column-width'>#{embed.to_s}</iframe>").children[0]
        embed.replace figure
      end
    else
      body # Do nothing if we have no embeditor instance.
    end
  end

  def wrap_iframes body
    # Iframes should be embedded in a figure tag with op-interactive class.
    # This will take care of our dynamic embeds as well as iframes inserted
    # by the author.
    process_markup body, 'iframe' do |iframe|
      figure = Nokogiri::HTML::DocumentFragment.parse("<figure class='op-interactive'>#{iframe.to_s}</figure>").children[0]
      iframe.replace figure
    end
  end

  def strip_comments body
    doc = Nokogiri::HTML(body.force_encoding('ASCII-8BIT'))
    doc.xpath('//comment()').remove
    doc.css("body").children.to_s.html_safe
  end

  def remove_empty_paragraphs body
    process_markup body, "p" do |tag|
      contents = tag.content
      if tag.content.strip.empty? || tag.content.strip == "&nbsp;"
        tag.remove if tag.content.strip.empty?
      end
    end
  end

  def translate_headings body
    # For whatever reason, Facebook only allows h1 and h2 tags.
    # H3 is reserved for "kickers", but it's unclear why others
    # are not permitted.  
    # While they will automatically translate h(n>2) tags to
    # h2, a warning is still displayed next to each story.
    # We will translate the tags here to prevent that warning.
    process_markup body, "h1, h2, h3, h4, h5, h6" do |heading|
      heading.inner_html = heading.text # Headings shouldn't contain other tags.
      unless ['h1', 'h2'].include?(heading.name.downcase)
        heading.name = "em"
      end
    end
  end

  def insert_inline_assets content, options={}
    cssPath = "img.inline-asset[data-asset-id]"
    context = options[:context] || "news"
    display = options[:display] || "inline"
    doc = Nokogiri::HTML(content.body)
    doc.css(cssPath).each do |placeholder|
      asset_id = placeholder.attribute('data-asset-id').value
      asset = content.assets.find_by(asset_id:asset_id)
      if asset
        rendered_asset = render_asset content, context: context, display: display, asset:asset
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse(rendered_asset)
      else
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse("")
      end
    end
    doc.css("body").children.to_s.html_safe
  end

  def paragraphatize content
    # Sometimes we don't have paragraphs but <br> tags!  Blech.
    # I suspect content comes in this way from people cutting
    # and pasting, but that's just a guess.  I've seen this happen
    # a few times.  If we can convert breaks to paragraphs, we should.
    
    # P tags can only contain inline elements, so this is a list of them all.
    inline_tags = %w(b big i small tt abbr acronym cite code dfn em kbd strong samp time var a bdo br img map object q script span sub sup button input label select textarea)
    line_splitter = /\r?\n|<br\s*\/*>|<\/*p\s*>/ # split by newlines, br, and p
    lines = content.split(line_splitter).reject(&:empty?)
    lines.map do |line|
      tags = line.scan(/<\s*(\w+)?.*>/).to_a.flatten
      # if line contains only inline elements
      if tags.map{|t| inline_tags.include?(t.downcase)}.all?{|t| t}
        "<p>#{line}</p>"
      else
        # if line contains block elements
        "#{line}<br>"
      end
    end.join("")
  end

  private

  def process_markup html, selector, &block
    doc = Nokogiri::HTML(html)
    doc.css(selector).each{|element|
      yield element, doc
    }
    doc.css('body').children.to_s.html_safe
  end
end