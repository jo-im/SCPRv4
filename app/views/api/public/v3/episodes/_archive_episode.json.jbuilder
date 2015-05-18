json.cache! [Api::Public::V3::VERSION, "v2", episode] do
  json.id           episode.id
  json.title        episode.headline
  json.public_url   episode.public_url
  json.published_at episode.published_at
end
