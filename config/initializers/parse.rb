if Rails.configuration.x.api.parse
  Parse.init(Rails.configuration.x.api.parse.symbolize_keys)
else
  Rails.logger.warn "Parse configuration is missing."
end
