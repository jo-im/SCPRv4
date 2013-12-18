Scprv4::Application.configure do
  config.cache_classes  = true
  config.eager_load     = false

  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :redis_content_store, "redis://localhost:6379/4"
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Allow pass debug_assets=true as a query parameter to
  # load pages with unpackaged assets
  config.assets.allow_debugging = true

  default_url_options[:host] = "scpr.org"

  config.scpr.host         = "www.scpr.org"
  config.scpr.resque_queue = :scprv4
  config.scpr.media_root   = Rails.root.join("spec/fixtures/media")
  config.scpr.media_url    = "file://#{Rails.root.join("spec/fixtures/media")}"

  config.node.server = "http://localhost:13002"
end
