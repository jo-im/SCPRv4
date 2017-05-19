xml.rss(RSS_SPEC) do
  xml.channel do
    xml.title       @feed[:title]
    xml.link        @feed[:link] || "http://www.scpr.org"
    xml.description @feed[:description]
    @content.each do |content|
      xml.item do
        xml.title content.title
        xml.guid  content.public_url
        xml.link  content.public_url
        xml.author content.byline
        xml.pubDate content.public_datetime

        if audio = (content.audio || []).first
          xml.tag!('enclosure', {
            :url => (audio.url || "").gsub("http://", "https://"),
            :type => "audio/mpeg"
          })
        end

        xml.description content.teaser
      end
    end
  end
end
