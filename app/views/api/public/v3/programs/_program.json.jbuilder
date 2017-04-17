json.cache! [Api::Public::V3::VERSION, "v1", program] do
  json.title          program.title
  json.slug           program.slug
  json.air_status     program.air_status
  json.twitter_handle program.get_link('twitter') if program.get_link('twitter').present?

  json.host         program.host
  json.airtime      program.airtime
  json.description  program.description.to_s.html_safe

  json.podcast_url(program.podcast_url) if program.podcast_url.present?
  json.rss_url(program.rss_url) if program.rss_url.present?
  json.public_url  program.public_url

  json.is_kpcc program.is_kpcc
  json.cover_thumbnail_image_url do
    json.set! "1x", "https://media.scpr.org/iphone/avatar-images/program_avatar_#{program.slug}.png"
    json.set! "2x", "https://media.scpr.org/iphone/avatar-images/program_avatar_#{program.slug}@2x.png"
  end
end
