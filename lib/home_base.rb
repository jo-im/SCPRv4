module HomeBase
  ## This is a simple module for taking care of 
  ## indexing of the new homepage model.  These functions
  ## are generally called asynchronously by the 
  ## HomepageIndexer job.
  ESClient = ES_CLIENT
  ESIndex  = ES_HOMEPAGES_INDEX
  class << self
    def index homepage
      ESClient.index index: ESIndex, type: 'homepage', id: homepage.id, body: homepage.to_indexable
    end
    def unindex homepage
      ESClient.delete index: ESIndex, type: 'homepage', id: homepage.id
    end
    def find obj
      if obj.respond_to?(:id)
        id = obj.id
      else
        id = obj
      end
      result = ESClient.get index: ESIndex, type: 'homepage', id: id
      decorate_result result
    end
    def search body:{}
      search_hash = {index: ESIndex, type: 'homepage', body: body}
      decorate_results ESClient.search search_hash
    end
    def current
      # Returns index entry for current homepage.
      search(body: {
        query: {
          match_all: {}
        },
        size: 1,
        sort: [
          {
            published_at: {
              order: "desc"
            }
          }
        ]        
      })[0]
    end

    private

    def create_index
      ESClient.indices.create index: ESIndex
    end

    def put_index_mapping
      mapping = JSON.parse(File.read("#{Rails.root}/config/homepage_mapping.json"))
      ESClient.indices.put_template name:"#{ES_PREFIX}-homepages", body:{template:"#{ES_PREFIX}-homepages-*",mappings:mapping}
    end

    def decorate_result result
      result   = result['_source']['table']
      decorate_related_article_collection (result['content'] || [])
      Hashie::Mash.new result
    end

    def decorate_related_article_collection collection
      # if a provided collection is a list of records that
      # reference articles, this will find the related
      # articles and append them to their respective records
      # in the collection.
      collection.map!{|r| Hashie::Mash.new(r['table'])}
      obj_keys = collection.map(&:obj_key)
      articles = ContentBase.search(with: { obj_key: obj_keys })
      articles.each do |article|
        if c = collection.find{|c| c.obj_key == article.obj_key}
          c.article = article
        end
      end
      collection.select!(&:article) # if an article was arbitrarily deleted, it should not show up in our results
    end

    def decorate_results results
      results['hits']['hits'].map do |hit|
        decorate_result hit
      end    
    end
  end
end