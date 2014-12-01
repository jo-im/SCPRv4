module Concern::Model::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name "#{ES_PREFIX}-models"

    def as_indexed_json(opts={})
      # strip out the extra bits that Outpost injects into our model
      as_json(opts).except("to_title","link_path","edit_path")
    end
  end
end