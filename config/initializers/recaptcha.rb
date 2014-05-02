Recaptcha.configure do |config|
  config.public_key = Rails.application.config.api["recaptcha"]["public_key"]
  config.private_key = Rails.application.config.api["recaptcha"]["private_key"]
end
