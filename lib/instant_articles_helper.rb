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

  def pipeline_filter record
    pipeline = ::HTML::Pipeline.new([
      Filter::CleanupFilter, 
      Filter::EmbeditorFilter,
      Filter::InstantArticlesFilter
      ], content: record)
    raw pipeline.call(record.body)[:output].to_s
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

  extend self
end