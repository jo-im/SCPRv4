xml.rss({"xmlns:nprml"=>"http://api.npr.org/nprml"}) do
  xml.channel do
    @content.each do |content|
      xml.item do
        xml.title content.title
        xml.guid  content.public_url
        xml.link  content.public_url
        xml.author content.byline
        xml.pubDate content.public_datetime

        if audio = (content.audio || []).first
          xml.tag!('enclosure', {
            :url => audio.url,
            :type => "audio/mpeg",
            "nprml:download" => true
          })
        end

        xml.description content.teaser
      end
    end
  end
end
