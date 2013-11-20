# First configure, because Secretary::Version uses the confiration
Secretary.configure do |config|
  config.user_class = "::AdminUser"
end

# Then require secretary/version so we know it's loaded before we
# force-feed it a spoonful of Outpost.
require 'secretary/version'

# nom nom nom
Secretary::Version.instance_eval do
  outpost_model
end
