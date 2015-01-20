Scprv4::Application.configure do
  config.cache_classes  = true
  config.eager_load     = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store, config.secrets.cache.servers, config.secrets.cache.options||{}
  config.action_controller.action_on_unpermitted_parameters = :log

  config.assets.debug         = false
  config.serve_static_assets  = false
  config.assets.digest        = true
  config.assets.compile       = false

  config.assets.js_compressor  = :uglifier
  config.assets.css_compressor = :sass

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Enable Postmark for transactional mail sending
  config.action_mailer.delivery_method          = :postmark
  config.action_mailer.raise_delivery_errors    = true
  config.action_mailer.postmark_settings = {
    :api_key => config.api['postmark']['api_key']
  }


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.scpr.media_root   = "/scpr/scprv4_production/media"
  config.scpr.media_url    = "http://media.scpr.org"
  config.scpr.resque_queue = :scprv4

  config.newsroom.server = "http://newsroom.scprdev.org:8020"
end
