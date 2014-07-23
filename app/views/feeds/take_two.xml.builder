xml.rss({"xmlns:nprml"=>"http://api.npr.org/nprml"}) do
  xml.channel do
    @segments.each do |segment|
      xml.item do
        xml.title segment.headline
        xml.guid  segment.public_url
        xml.link  segment.public_url
        xml.author segment.byline

        if asset = segment.asset
          xml.enclosure({
            :url      => asset.full.url,
            :type     => "image/jpeg",
            :length   => asset.image_file_size.to_i / 100
          })
        end

        if audio = segment.audio
          audio.each do |a|
            xml.tag!('enclosure', {
              :url => a.url,
              :type => "audio/mp3",
              "nprml:download" => true
            })
          end
        end

        description = ""
        description << relaxed_sanitize(segment.body)
        xml.description description
      end
    end
  end
end
