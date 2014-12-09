Scprv4::Application.configure do
  config.cache_classes  = true
  config.eager_load     = true
  config.consider_all_requests_local = true

  # There's nothing expiring the cache on staging so don't use it
  # If you change this to true, manually expire the cache
  # by SSHing to the server and running `Rails.cache.clear`
  # from the Rails console.

  # You can also switch this to true, change the Redis path to point to cache1,
  # and change staging in database.yml to use mercer_new (production).
  # That would be good for figuring out a problem that was only occurring
  # in production.

  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store, config.secrets.cache.servers, config.secrets.cache.options||{}
  config.action_controller.action_on_unpermitted_parameters = :log

  config.assets.debug         = false
  config.serve_static_assets  = false
  config.assets.digest        = true
  config.assets.compile       = false

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

  config.dbsync = {
    :local   => "/web/scprv4/dbsync/mercer.dump",
    :remote  => "scprdb@66.226.4.229:~scprdb/mercer.dump"
  }

  config.scpr.media_root   = "/scpr/media"
  config.scpr.media_url    = "http://media.scpr.org"
  config.scpr.resque_queue = :scprv4

  config.newsroom.server = "http://newsroom.scprdev.org:8020"
end
