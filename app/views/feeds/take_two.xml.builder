xml.rss({"xmlns:nprml"=>"http://api.npr.org/nprml"}) do
  xml.channel do
    @segments.each do |segment|
      xml.item do
        xml.title segment.headline
        xml.guid  segment.public_url
        xml.link  segment.public_url
        xml.author segment.byline
        xml.pubDate segment.published_at

        if audio = segment.audio
          audio.each do |a|
            xml.tag!('enclosure', {
              :url => a.url,
              :type => "audio/mp3",
              "nprml:download" => true
            })
          end
        end

        xml.description relaxed_sanitize(segment.body)
      end
    end
  end
end
