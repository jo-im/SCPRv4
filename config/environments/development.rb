Scprv4::Application.configure do
  config.cache_classes  = false
  config.eager_load     = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  #config.cache_store = :dalli_store, "localhost:11211", { namespace:"scprv4" }
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.active_record.raise_in_transactional_callbacks = true

  config.assets.debug         = true # Expand
  config.serve_static_files   = true  # Serve from public/
  config.assets.compile       = true  # Fallback
  config.assets.digest        = false # Add asset fingerprints

  config.assets.js_compressor = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :stderr

  config.action_mailer.delivery_method       = :smtp
  config.action_mailer.raise_delivery_errors = true

  config.dbsync = {
    :local => "~/dbsync-scpr.sql",
    :remote => "ftp://backups.i.scprdev.org/database/scpr-latest.sql.gz",
    :strategy => :curl,
    :bin_opts => "--netrc"
  }

  config.x.scpr.host          = ENV["SCPRV4_HOST"]              || "scprv4.dev"
  config.x.scpr.audio_root    = ENV["SCPRV4_AUDIO_ROOT"]        || false
  config.x.scpr.media_url     = ENV["SCPRV4_MEDIA_URL"]         || "http://media.scpr.org"
  config.x.newsroom.url           = ENV["SCPRV4_NEWSROOM"]          || "http://localhost:8888"

  config.x.assethost.raise_on_errors = true

  config.x.scpr.elasticsearch_host    = ENV["SCPRV4_ELASTICSEARCH_HOST"]    || "127.0.0.1:9200"
  config.x.scpr.elasticsearch_prefix  = ENV["SCPRV4_ELASTICSEARCH_PREFIX"]  || "scprv4"

  default_url_options[:host] ||= config.x.scpr.host
end
