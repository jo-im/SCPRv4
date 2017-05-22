xml.rss(RSS_SPEC) do
  xml.channel do
    # xml.title       @feed[:title]
    # xml.link        @feed[:link] || "http://www.scpr.org"
    # xml.description @feed[:description]
    xml.ttl 30
    @content.each do |content|
      xml.item do
        xml.title content.title
        xml.link  content.public_url
        xml.pubDate content.public_datetime
        xml.description content.teaser
        xml.guid  content.public_url
                
        if audio = (content.audio || []).first
          xml.tag!('enclosure', {
            :url => (audio.url || "").gsub("http://", "https://"),
            :type => "audio/mpeg"
          })
        end

      end
    end
  end
end
