# support pulling in audio path settings from secrets.yml
[:media_root,:audio_root,:audio_url,:podcast_url].each do |k|
  Rails.configuration.x.scpr[k] ||= Rails.application.secrets[k]
end

# support using media_root until we've switched people over
Rails.configuration.x.scpr.audio_root ||= Rails.configuration.x.scpr.media_root ? File.join(Rails.configuration.x.scpr.media_root, "audio") : false

# transitioning from media_url -> audio_url
Rails.configuration.x.scpr.audio_url ||= Rails.configuration.x.scpr.media_url ? File.join(Rails.configuration.x.scpr.media_url, "audio") : false

# transitioning from media_url -> podcast_url
Rails.configuration.x.scpr.podcast_url ||= Rails.configuration.x.scpr.media_url ? File.join(Rails.configuration.x.scpr.media_url, "podcasts") : false