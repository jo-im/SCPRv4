if Rails.application.config.api['parse']
  Parse.init(Rails.application.config.api['parse'].symbolize_keys)
else
  Rails.logger.warn "Parse configuration is missing."
end
