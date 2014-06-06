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
    xml << render_content(@segments.first(15), "feedxml", {
      :context => @program.slug
    })
  end
end
