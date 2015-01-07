module Concern::Model::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name "#{ES_PREFIX}-models"

    [:create,:update,:destroy].each do |a|
      after_commit on:a do
        Job::Indexer.enqueue self.class.to_s, self.id, a.to_s
      end
    end

    def as_indexed_json(opts={})
      model = self.class.name.underscore
      h = as_json(opts)
      {}.merge(h[ model ]).merge(h).except(model)
    end
  end
end