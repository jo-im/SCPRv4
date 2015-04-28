if Rails.application.config.api['assethost']
  Rails.application.config.assethost.server = Rails.application.config.api['assethost']['server']
  Rails.application.config.assethost.prefix = Rails.application.config.api['assethost']['prefix']
  Rails.application.config.assethost.token  = Rails.application.config.api['assethost']['token']
else
  Rails.logger.warn "Assethost configuration is missing."
end
