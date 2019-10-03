# Support loading config via secrets.yml
if Rails.application.secrets.assethost.is_a?(Hash)
  Rails.application.secrets.assethost.each do |k,v|
    Rails.configuration.x.assethost[k] ||= v
  end
end

# Configure AssetHostClient
AssetHostClient.setup do |config|
  config.protocol         = Rails.configuration.x.assethost.protocol
  config.server           = Rails.configuration.x.assethost.server
  config.token            = Rails.configuration.x.assethost.token
  config.raise_on_errors  = Rails.configuration.x.assethost.raise_on_errors || false
  config.open_timeout     = Rails.configuration.x.assethost.open_timeout || 1
  config.timeout          = Rails.configuration.x.assethost.timeout || 2
end