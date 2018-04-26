cache ["v4", @podcast, @consumer], expires_in: 1.hour do # Podcasts will refresh every hour.
  xml.rss(
    'version'         => "2.0",
    'xmlns:atom'      => "http://www.w3.org/2005/Atom",
    'xmlns:itunes'    => "http://www.itunes.com/dtds/podcast-1.0.dtd",
    'xmlns:megaphone' => "https://developers.megaphone.fm"
  ) do
    xml.channel do
      xml.title @podcast.title
      xml.link  @podcast.url || root_url

      xml.atom :link,
        :href => @podcast.url || root_url,
        :rel  => "alternate"

      xml.atom :link, {
        :href   => @podcast.public_url,
        :rel    => "self",
        :type   => "application/rss+xml"
      }

      xml.language          "en-us"
      xml.description       h(@podcast.description)
      xml.itunes :author,   @podcast.author
      xml.itunes :summary,  h(@podcast.description)

      xml.itunes :category,
        text: @podcast.itunes_category || "News & Politics"

      xml.itunes :owner do
        xml.itunes :name,  "KPCC 89.3 | Southern California Public Radio"
        xml.itunes :email, "contact@kpcc.org"
      end

      xml.itunes :image, :href => @podcast.image_url
      xml.itunes :explicit, "no"

      @podcast.content(40).each do |article|
        audio = article.audio.first

        xml.item do |item|
          item.megaphone :externalId,   "#{article.obj_key}__#{Rails.env}"
          item.title                    raw(article.title)
          item.itunes :author,          raw(@podcast.author)
          item.itunes :summary,         raw(article.teaser)
          item.description              raw(article.teaser)
          item.guid                     article.public_url, :isPermaLink => true
          item.pubDate                  article.public_datetime.in_time_zone("GMT").strftime("%a, %d %b %Y %T %Z")
          item.itunes :keywords,        raw(@podcast.keywords)
          item.link                     article.public_url

          item.enclosure({
            :url => url_with_params(audio.podcast_url, {
              :context    => @podcast.context,
              :via        => "podcast",
              :consumer   => @consumer,
            }),
            :length => audio.size,
            :type   => "audio/mpeg"
          })

          item.itunes :duration,  audio.duration
        end # xml
      end # @article
    end # xml.channel
  end.html_safe #xml.rss
end # cache
