require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module Scprv4
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/validators"
    ]

    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.paths << "#{Rails.root}/vendor/assets/fonts"
    config.assets.precompile += [
      "shared.js",
      "outpost/application.css",
      "outpost/application.js",
      "base/print.css",
      "new/application.js",
      "new/application.css",
      "new/ie-lt9.js", # For ie < 9, separate include
      "new/ie-lt9.css" # For ie < 9, separate include
    ]
    config.assets.js_compressor  = :uglifier
    config.assets.css_compressor = :sass
    config.assets.compile = false # Fallback?

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
    config.dbsync     = ActiveSupport::OrderedOptions.new

    config.api = YAML.load_file(
      "#{Rails.root}/config/api_config.yml"
    )[Rails.env]

    config.secrets = YAML.load_file("#{Rails.root}/config/app_config.yml")

    config.action_mailer.simple_postmark_settings = {
      :api_key => config.api['postmark']['api_key']
    }

    config.assethost.server = config.api['assethost']['server']
    config.assethost.prefix = config.api['assethost']['prefix']
    config.assethost.token  = config.api['assethost']['token']
  end
end
