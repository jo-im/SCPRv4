ES_CLIENT = Elasticsearch::Client.new(
  hosts:              Rails.configuration.secrets.elasticsearch_host,
  retry_on_failure:   3,
  reload_connections: true,
)

ES_PREFIX = Rails.configuration.secrets.elasticsearch_prefix

ES_ARTICLES_INDEX = "#{ES_PREFIX}-articles-all"

Elasticsearch::Model.client = ES_CLIENT

Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari

begin
  # try this, but don't abort startup if it fails
  Article._put_article_mapping
rescue
end