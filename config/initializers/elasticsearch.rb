ES_CLIENT = Elasticsearch::Client.new(
  hosts: [{
                            host: Rails.application.secrets.elasticsearch["host"],
                            port: Rails.application.secrets.elasticsearch["port"],
                            user: Rails.application.secrets.elasticsearch["user"],
                            password: Rails.application.secrets.elasticsearch["password"],
                            scheme: Rails.application.secrets.elasticsearch["scheme"]
           }],
  retry_on_failure:   3,
  reload_connections: true,
  transport_options: {
    request: { timeout: 20 },
  },
)

ES_PREFIX = Rails.configuration.x.scpr.elasticsearch_prefix || Rails.application.secrets.elasticsearch_prefix

ES_ARTICLES_INDEX  = "#{ES_PREFIX}-articles-all"

ES_HOMEPAGES_INDEX = "#{ES_PREFIX}-homepages-all"

ES_MODELS_INDEX = "#{ES_PREFIX}-models"

Elasticsearch::Model.client = ES_CLIENT

Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari
