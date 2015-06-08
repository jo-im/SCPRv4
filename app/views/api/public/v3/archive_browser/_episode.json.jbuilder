json.cache! [Api::Public::V3::VERSION, "v2", episode] do
  json.id           episode.id
  json.title        episode.title
  json.public_url   episode.public_url
  json.air_date     episode.air_date
end
