options[:enclosure_type] ||= article.audio.present? ? :audio : :image

xml.item do
  xml.title article.title
  xml.guid  article.public_url
  xml.link  article.public_url
  xml.dc :creator, article.byline


  if options[:enclosure_type] == :image
    if asset = article.assets.first
      xml.enclosure({
        :url      => asset.full.url,
        :type     => "image/jpeg",
        :length   => asset.image_file_size.to_i / 100
      })
    end
  else
    if audio = article.audio.first
      xml.enclosure({
        :url => url_with_params(audio.url, {
          :context    => options[:context],
          :via        => 'rss'
        }),
        :type   => "audio/mpeg",
        :length => audio.size.present? ? audio.size : "0"
      })
    end
  end


  description = ""

  description << render_asset(article, template: "default/feedxml")
  description << relaxed_sanitize(article.body)

  if article.original_object.is_a? ContentShell
    description << content_tag(:p,
      link_to(
        "Read the full article at #{article.original_object.site}".html_safe,
        article.public_url
      )
    )
  end


  xml.description description
  xml.pubDate article.public_datetime.rfc822
end
