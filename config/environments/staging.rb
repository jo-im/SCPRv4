Scprv4::Application.configure do
  config.cache_classes  = true
  config.eager_load     = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true
  config.action_controller.action_on_unpermitted_parameters = :log

  # The :expires_in value of 604800 is 1 week in seconds
  config.cache_store = :dalli_store, Rails.application.secrets.cache["servers"], Rails.application.secrets.cache["options"] || { :expires_in => 604800 }

  config.active_record.raise_in_transactional_callbacks = true

  config.assets.debug         = false
  config.serve_static_files  = false
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
    :api_key => Rails.application.secrets.api['postmark']['api_key']
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  default_url_options[:host]     = config.x.scpr.host = Rails.application.secrets.host
  default_url_options[:protocol] = config.x.scpr.protocol = 'https'
end
