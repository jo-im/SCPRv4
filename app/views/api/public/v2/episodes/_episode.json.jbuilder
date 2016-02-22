json.cache! [Api::Public::V2::VERSION, "v3", episode] do
  json.title    episode.title
  json.summary  episode.summary.to_s.html_safe

  json.air_date     episode.air_date
  json.public_url   episode.public_url

  json.assets do |asset|
    json.partial! "api/public/v2/assets/collection",
      assets: episode.assets
  end

  json.audio do
    json.partial! "api/public/v2/audio/collection",
      audio: episode.audio
  end

  json.program do
    json.partial! "api/public/v2/programs/program",
      program: episode.program
  end

  # ShowSegments used to wrap themselves in an episode with to_episode,
  # but we removed that. This is here to keep API v2 the same.
  if episode.program.is_segmented?
    segments = episode.segments.map(&:to_article)
  else
    segments = Array(episode.original_object.to_article)
  end

  json.segments do
    json.partial! 'api/public/v2/articles/collection',
      articles: segments
  end

  json.teaser episode.summary.to_s.html_safe # Deprecated

  json.content do
    json.partial! 'api/public/v2/articles/collection',
      articles: episode.content.map(&:to_article)
  end

end
