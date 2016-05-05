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
      content  = result['content']
      content.map!{|r| Hashie::Mash.new(r['table'])}
      obj_keys = content.map(&:obj_key)
      articles = ContentBase.search(with: { obj_key: obj_keys })

      # attach articles to their respective homepage contents
      articles.each do |article|
        if c = content.find{|c| c.obj_key == article.obj_key}
          c.article = article
        end
      end

      content.select!(&:article) # if an article was arbitrarily deleted, it should not show up in our results

      Hashie::Mash.new result
    end

    def decorate_results results
      results['hits']['hits'].map do |hit|
        decorate_result hit
      end    
    end
  end
end