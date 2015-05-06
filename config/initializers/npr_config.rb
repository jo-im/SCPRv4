## NPR gem configuration
if Rails.configuration.x.api.npr
  NPR.configure do |config|
    config.apiKey = Rails.configuration.x.api.npr.api_key
  end
else
  Rails.logger.warn "NPR configuration is missing. No API key found."
end