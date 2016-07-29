xml.rss(RSS_SPEC) do
  xml.channel do
    xml.title       @feed[:title]
    xml.link        @feed[:link] || "http://www.scpr.org"
    xml.description @feed[:description]
    xml.language 'en-us'
    xml.atom :link, {
      :href   => @feed[:url],
      :rel    => "self",
      :type   => "application/rss+xml"
    }
    @content.each do |content|
      xml.item do
        xml.title content.title
        xml.description render(
          partial: 'feeds/shared/apple_article', 
          formats: ['html'],
          layout: false, 
          locals: {content: content}
        ).gsub("\n", "")
        xml.guid    content.public_url
        xml.link    content.public_url
        xml.author  content.byline
        if content.asset
          xml.enclosure url: content.asset.full.url, type: "image/jpeg"
        end
        xml.pubDate content.public_datetime.iso8601
      end
    end
  end
end