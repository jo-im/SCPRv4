# Deprecation for config.node.
# This can be removed any time, just make sure all the devs have made
# this change.
# When you remove this deprecation warning, be sure to remove the 'config.node'
# line in application.rb as well.
if Rails.application.config.node.server.present?
  ActiveSupport::Deprecation.behavior = :stderr

  ActiveSupport::Deprecation.warn(
    "'config.node' is deprecated. " \
    "Update your development.rb to use 'config.newsroom' instead. " \
    "See config/templates/development.rb for an example.")

  Rails.application.config.newsroom = Rails.application.config.node
  Rails.application.config.node = nil
end
