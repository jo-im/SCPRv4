ES_CLIENT = Elasticsearch::Client.new(
  hosts:              Rails.configuration.x.scpr.elasticsearch_host || Rails.application.secrets.elasticsearch_host,
  retry_on_failure:   3,
  reload_connections: true,
  transport_options: {
    request: { timeout: 20 },
  },
)

ES_PREFIX = Rails.configuration.x.scpr.elasticsearch_prefix || Rails.application.secrets.elasticsearch_prefix

ES_ARTICLES_INDEX  = "#{ES_PREFIX}-articles-all"

ES_HOMEPAGES_INDEX = "#{ES_PREFIX}-homepages-all"

Elasticsearch::Model.client = ES_CLIENT

Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari
