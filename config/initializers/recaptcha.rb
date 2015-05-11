if Rails.configuration.x.api.recaptcha
  Recaptcha.configure do |config|
    config.public_key   = Rails.configuration.x.api.recaptcha.public_key
    config.private_key  = Rails.configuration.x.api.recaptcha.private_key
  end
else
  Rails.logger.warn "Recaptcha config is missing."
end