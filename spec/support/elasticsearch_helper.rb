module ElasticsearchHelper
  def reset_es
    # Clean up
    ContentBase.es_client.indices.delete index:"_all"

    # And because some specs don't need to insert content, but do need
    # content lookups to succeed, go ahead and create the articles index
    ContentBase.es_client.indices.create index:ES_ARTICLES_INDEX
  end

  def with_indexing
    Resque.run_in_tests = (Resque.run_in_tests + [IndexJob]).uniq

    yield

    Resque.run_in_tests.delete(IndexJob)
  end
end