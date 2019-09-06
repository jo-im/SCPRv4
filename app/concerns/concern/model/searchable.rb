module Concern::Model::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name ES_MODELS_INDEX
    document_type "OutpostModel"

    [:create,:update,:destroy].each do |a|
      after_commit on:a do
        async_index action: a.to_s
      end
    end

    after_initialize :lazy_index

    class << self
      def set_to_reindex
        update_all needs_reindex: true
      end
    end

    class << self
      def index_all
        find_in_batches(batch_size: 100) do |batch|
          batch.each do |object|
            object.async_index
          end
        end
      end
    end

    def as_indexed_json(opts={})
      model = self.class.name.underscore
      h = as_json(opts)
      hash_to_return =
        if h[ model ]
          h[model].delete('needs_reindex') #grumble
          {}.merge(h[ model ]).merge(h).merge({type: model}).except(model)
        else
          h
        end
      return hash_to_return
    end

    def get_article
      ## retrieve article from content_base, else perform #to_article and index for future
      @to_article ||=
        if article = ContentBase.find(obj_key)
          article
        else
          async_index
          to_article
        end
    end

    def to_reference
      thumbnail = (self.try(:assets) || []).first.try(:asset).try(:json).try(:[], 'urls').try(:[], 'thumb');
      { 
        id:              self.obj_key,
        public_path:     self.public_path,
        title:           self.try(:headline) || self.try(:title),
        short_title:     self.try(:short_headline) || self.try(:headline) || self.try(:short_title) || self.try(:title),
        category:        self.try(:category),
        thumbnail:       thumbnail,
        public_datetime: self.try(:published_at) || self.try(:starts_at) || self.try(:created_at),
        has_audio?:      (self.try(:audio) || []).any?,
        has_assets?:     (self.try(:assets) || []).any?
      }
    end

    def async_index action: :create 
      Job::Indexer.enqueue(self.class.to_s, id, action)
    end

    def index
      # the models index (used in Outpost)
       __elasticsearch__.index_document

      # update the Article index if appropriate
      if respond_to?(:to_article)
        # eh, a one-item bulk operation? Not very bulk...
        ContentBase.es_client.bulk body: to_article.to_es_bulk_operation
      end   
    end

    def lazy_index
      # rather than run a lengthy job to index all articles
      # just reindex the object after initialization if
      # #needs_reindex? returns true.  The call to #index
      # needs to be synchronous, else a template may show
      # no related content(for example) because it is a 
      # new attribute that has not yet been indexed.
      if has_attribute?(:needs_reindex) && needs_reindex?
        index
        update_attribute(:needs_reindex, false)
      end
    end

  end
end