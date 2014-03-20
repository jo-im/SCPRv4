Scprv4::Application.configure do
  config.cache_classes  = true
  config.eager_load     = false
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
  config.cache_store = :redis_content_store, "redis://localhost:6379/6"
  config.action_controller.action_on_unpermitted_parameters = :raise

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
    :filename    => "mercer.dump",
    :local_dir   => "/web/scprv4/dbsync",
    :remote_host => "scprdb@66.226.4.229",
    :remote_dir  => "~scprdb"
  }

  default_url_options[:host] = "staging.scprdev.org"

  config.scpr.host         = "staging.scprdev.org"
  config.scpr.media_root   = "/home/kpcc/media"
  config.scpr.media_url    = "http://media.scpr.org"
  config.scpr.resque_queue = :scprv4

  config.node.server = "http://node.scprdev.org"
end
