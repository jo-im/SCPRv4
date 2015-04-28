# support using media_root until we've switched people over
Rails.application.config.scpr.audio_root ||= Rails.application.config.scpr.media_root ? File.join(Rails.application.config.scpr.media_root, "audio") : false

# transitioning from media_url -> audio_url
Rails.application.config.scpr.audio_url ||= Rails.application.config.scpr.media_url ? File.join(Rails.application.config.scpr.media_url, "audio") : false

# transitioning from media_url -> podcast_url
Rails.application.config.scpr.podcast_url ||= Rails.application.config.scpr.media_url ? File.join(Rails.application.config.scpr.media_url, "podcasts") : false