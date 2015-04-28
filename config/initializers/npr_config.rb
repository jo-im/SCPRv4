## NPR gem configuration
if Rails.application.config.api["npr"]
  NPR.configure do |config|
    config.apiKey = Rails.application.config.api["npr"]["api_key"]
  end
else
  Rails.logger.warn "NPR configuration is missing. No API key found."
end