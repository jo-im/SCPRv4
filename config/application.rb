require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env)

if Rails.env.development? or Rails.env.test?
  ## Initialize Docker Machine environment variables so
  ## that database.yml can pick up the MySQL database host
  `docker-machine env default`.scan(/(\w+)="(.*)"/).each{|p| ENV[p[0]] = p[1]}
  ENV['SCPRV4_DEVELOPMENT_DATABASE_IP'] = URI(ENV['DOCKER_HOST']).host
end

module Scprv4
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/validators",
      "#{config.root}/app/models/pmp",
      "#{config.root}/app/models/content_base"
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

    config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""

    config.time_zone = 'Pacific Time (US & Canada)'
    config.active_record.default_timezone = :local

    config.i18n.enforce_available_locales = false
    config.encoding = "utf-8"
    config.middleware.insert 0, Rack::UTF8Sanitizer
    # config.middleware.use 'HomepageOptIn'
    config.middleware.use "SafeFilename"

    # Temporary until we can go into the controllers and set
    # all this up
    config.action_controller.permit_all_parameters = true

    config.filter_parameters += [
      :password,
      :unencrypted_password,
      :auth_token
    ]

    config.assets.paths << Rails.root.join("node_modules")

    # Dir.glob("#{Rails.root}/node_modules/**/").each do |path|
    #   config.assets.paths << path
    # end
  end
end
