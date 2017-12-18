xml.rss(RSS_SPEC) do
  xml.channel do
    xml.title       "Blog: #{@blog.name} | 89.3 KPCC"
    xml.link        @blog.public_url
    xml.description strip_tags(@blog.description)

    xml.atom :link, {
      :href   => @blog.public_url(format: :xml),
      :rel    => "self",
      :type   => "application/rss+xml"
    }

    xml << render_content(@entry, "feedxml", {
      :context => @blog.slug
    })
  end
end
