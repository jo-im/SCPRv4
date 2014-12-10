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
      # strip out the extra bits that Outpost injects into our model
      as_json(opts).except("to_title","link_path","edit_path")
    end
  end
end