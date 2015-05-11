if Rails.configuration.x.api.parse
  Parse.init(Rails.configuration.x.api.parse.to_h.symbolize_keys)
else
  Rails.logger.warn "Parse configuration is missing."
end
