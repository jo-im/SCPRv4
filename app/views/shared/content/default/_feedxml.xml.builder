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
  if article.byline && !article.byline.empty?
    description << content_tag(:p) do
      content_tag(:address, article.byline.html_safe)
    end
  end
  description << relaxed_sanitize(article.body)
  case article.original_object
  when ContentShell
    description << content_tag(:p,
      link_to(
        "Read the full article at #{article.original_object.site}".html_safe,
        article.public_url
      )
    )
  else
    description << content_tag(:p,
      link_to(
        "This content is from Southern California Public Radio. View the original story at SCPR.org.".html_safe,
        article.public_url
      )
    )
  end

  xml.description description
  xml.pubDate article.public_datetime.rfc822
end
