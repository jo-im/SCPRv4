xml.rss(RSS_SPEC) do
  xml.channel do
    xml.title  "#{@program.title} | 89.3 KPCC"
    xml.link   @program.public_url

    xml.atom :link, {
      :href => @program.public_url(format: :xml),
      :rel  => "self",
      :type => "application/rss+xml"
    }

    xml.description strip_tags(@program.description)

    if @program.is_segmented?
      xml << render_content(@program.segments.published.first(15), "feedxml", {
        :context => @program.slug
      })
    else
      xml << render_content(@episodes.first(15), "feedxml", {
        :context => @program.slug
      })
    end
  end
end
