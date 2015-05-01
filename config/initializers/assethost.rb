#if !Rails.configuration.assethost.server
#  Rails.logger.warn "Assethost configuration is missing."
#end

AssetHostClient.setup do |config|
  config.server           = Rails.configuration.x.assethost.server
  config.token            = Rails.configuration.x.assethost.token
  config.raise_on_errors  = Rails.configuration.x.assethost.raise_on_errors || false
end