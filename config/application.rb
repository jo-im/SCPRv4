require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env)

module Scprv4
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/validators"
    ]

    config.assets.version = '2.0'
    config.assets.precompile += [
      "webtrends.v2.js",
      "shared.js",
      "legacy.js",
      "outpost/application.css",
      "outpost/application.js",
      "base/print.css",
      "new/application.js",
      "new/application.css",
      "new/ie-lt9.js",  # For ie < 9, separate include
      "new/ie-lt9.css", # For ie < 9, separate include
      "*.eot", "*.ttf", "*.woff" # Font files
    ]
    config.assets.js_compressor  = :uglifier
    config.assets.css_compressor = :sass

    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    config.i18n.enforce_available_locales = false
    config.encoding = "utf-8"

    # Temporary until we can go into the controllers and set
    # all this up
    config.action_controller.permit_all_parameters = true

    config.filter_parameters += [
      :password,
      :unencrypted_password,
      :auth_token
    ]

    config.scpr       = ActiveSupport::OrderedOptions.new
    config.assethost  = ActiveSupport::OrderedOptions.new
    config.node       = ActiveSupport::OrderedOptions.new

    config.api = YAML.load_file(
      "#{Rails.root}/config/api_config.yml"
    )[Rails.env]

    config.secrets = YAML.load_file("#{Rails.root}/config/app_config.yml")

    config.assethost.server = config.api['assethost']['server']
    config.assethost.prefix = config.api['assethost']['prefix']
    config.assethost.token  = config.api['assethost']['token']
  end
end
