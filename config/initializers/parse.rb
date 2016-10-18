if Rails.configuration.x.api.parse
  Parse.init(Rails.configuration.x.api.parse.to_h.symbolize_keys)
else
  Rails.logger.warn "Parse configuration is missing."
end

if Rails.configuration.x.api.parse_local
  Farse.init(Rails.configuration.x.api.parse_local.to_h.symbolize_keys)
else
  Rails.logger.warn "Local Parse configuration is missing."
end