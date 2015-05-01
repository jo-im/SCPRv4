if !Rails.configuration.assethost.server
  Rails.logger.warn "Assethost configuration is missing."
end
