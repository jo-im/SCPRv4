Secretary.configure do |config|
  config.user_class = "::AdminUser"
end

Secretary::Version.instance_eval do
  outpost_model
end
