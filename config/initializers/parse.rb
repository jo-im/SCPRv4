if Rails.configuration.x.api.parse
  # FIXME: Symbolize?
  Parse.init(Rails.configuration.x.api.parse)
else
  Rails.logger.warn "Parse configuration is missing."
end
