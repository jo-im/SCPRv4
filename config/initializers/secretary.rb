# Configuration for Secretary
require_dependency "secretary"

Secretary.configure do |config|
  config.user_class = "::AdminUser"
end

# Setup Secretary to be Outposty
Secretary::Version.instance_eval do
  outpost_model
end
