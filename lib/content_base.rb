##
# ContentBase
#
# A set of definitions, collections, and utilities for
# content in the application.
#

module ContentBase
  @@es_client = ES_CLIENT
  @@es_index  = ES_ARTICLES_INDEX

  extend self

  STATUS_DRAFT = 0
  STATUS_LIVE = 5

  # Classes which are safe to fetch on the frontend.
  # This was added to make ContentMailer more safe.
  SAFE_CLASSES = [
    "NewsStory",
    "ShowSegment",
    "BlogEntry",
    "ContentShell",
    "Event",
    "PijQuery",
    "ShowEpisode",
    "Edition"
  ]

  #--------------------
  # URLS to match in ::obj_by_url
  CONTENT_MATCHES = {
    %r{\A/news/\d+/\d\d/\d\d/(\d+)/.*}                => 'NewsStory',
    %r{\A/blogs/[-_\w]+/\d+/\d\d/\d\d/(\d+)/.*}       => 'BlogEntry',
    %r{\A/programs/[\w_-]+/\d{4}/\d\d/\d\d/(\d+)/.*}  => 'ShowSegment'
  }


  # Don't set any of these to 0, because ThinkingSphinx will
  # convert NULL to 0 and return incorrect results.
  ASSET_DISPLAY_IDS = {
    :slideshow            =>       1,
    :video                =>       2,
    :photo_emphasized     =>       3,
    :photo_deemphasized   =>       4,
    :hidden               =>       5
  }

  ASSET_DISPLAYS = ASSET_DISPLAY_IDS.invert

  def self.es_client
    @@es_client
  end

  def self.es_index
    @@es_index
  end

  def new_obj_key
    "contentbase:new"
  end

  def _filter_for(k,v)
    # term filters
    return case v
    when Array
      { terms: { k => v } }
    when FalseClass
      { missing: { field: k } }
    when TrueClass
      { exists: { field: k } }
    when Range
      { range: { k => { gte: v.first, lt: v.last }}}
    when Regexp
      # When the corresponding value is a regular expression,
      # print it in a human readable format and shave off the first and last forward slahes
      { regexp: { k => v.inspect[1...-1] } }
    else
      { term: { k => v } }
    end
  end

  def active_query &block
    # This is a way to uniformly query content from our MySQL database as Articles.
    #
    # Provide your ActiveRecord query inside a block:
    #
    # `active_query {|query| query.where('id = ?', 3).limit(3)}`
    #
    ## obj_key(as id), headline, short_headline, teaser, body, category_id, status_id, published_at
    selects = [
      yield(NewsStory.select(   "CONCAT('news_story-', id) AS id",    :headline, :short_headline,              :teaser,              :body, :category_id, :status, :published_at)).to_sql,
      yield(ShowSegment.select( "CONCAT('show_segment-', id) AS id",  :headline, :short_headline,              :teaser,              :body, :category_id, :status, :published_at)).to_sql,
      yield(BlogEntry.select(   "CONCAT('blog_entry-', id) AS id",    :headline, :short_headline,              :teaser,              :body, :category_id, :status, :published_at)).to_sql,
      yield(ContentShell.select("CONCAT('content_shell-', id) AS id", :headline, "headline AS short_headline", "headline AS teaser", :body, :category_id, :status, :published_at)).to_sql
    ].map{|s| "(#{s})"}.join(" UNION ")
    ActiveRecord::Base.connection.exec_query(yield(NewsStory.select("*").from("(#{selects}) AS items")).to_sql).map{|i| Article.new(i)}
  end

  def histogram content_type, match, options={}
    query = {:query=>
      {:filtered=>
        {:query=>{:match_all=>{}}, :filter=>{:term=>match}}},
     :sort=>[{"public_datetime"=>{:order=>"desc"}}],
     :size=>0,
     :aggs=>
      {:years=>
        {
          :date_histogram=>{:field=>"public_datetime", :interval=>"year", :time_zone=>"-07:00", :format=>"YYYY"},
          :aggs => {
            :months=> {
              :date_histogram=>{:field=>"public_datetime", :interval=>"month", :time_zone=>"-07:00"}
            }
          }
        }
      }
    }
    es_client.search({index:@@es_index, type: content_type, body: query}.merge(options))
  end

  #--------------------
  # This is for making "raw" Elasticsearch queries.
  # Useful if #search isn't doing what you want, or
  # for testing out query structures copied from
  # documentation or Elasticsearch-SQL.

  def query query={}, options={}
    begin
      results = Hashie::Mash.new(@@es_client.search({index:@@es_index, body: query}.merge(options)))
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest
      return []
    end

    # -- convert results into Article objects -- #

    articles = results.hits.hits.collect do |r|
      # turn ES _source into Article
      Article.new(r._source.merge({
        id:               r._source.obj_key,
        public_datetime:  r._source.public_datetime ? Time.zone.parse(r._source.public_datetime) : nil,
        created_at:       Time.zone.parse(r._source.created_at),
        updated_at:       Time.zone.parse(r._source.updated_at),
      }).except(:obj_key))
    end

    # -- inject pagination bits into the array -- #

    articles.instance_variable_set :@_body, query

    articles.instance_variable_set :@_pagination, Hashie::Mash.new({
      per_page:       (query[:size] || 10),
      offset:         (query[:from] || 0),
      total_results:  results.hits.total,
    })

    articles.singleton_class.class_eval do
      define_method :current_page do
        ( @_pagination.offset / @_pagination.per_page ).floor + 1
      end

      define_method :total_pages do
        ( @_pagination.total_results.to_f / @_pagination.per_page.to_f ).ceil
      end

      define_method :offset_value do
        @_pagination.offset
      end

      define_method :limit_value do
        @_pagination.per_page
      end

      define_method :last_page? do
        @_pagination.current_page >= @_pagination.total_pages
      end

      define_method :results do
        @_pagination.total_results
      end
    end

    articles

  end

  #--------------------

  def search(*args)
    options       = args.extract_options!
    query_string  = args[0].to_s

    options.reverse_merge!({
      :classes     => [NewsStory, ShowSegment, BlogEntry, ContentShell, Event],
      :page        => 1,
      :order       => "public_datetime #{DESCENDING}"
    })

    # We'll want to search only among live content 99% of the
    # time. For the times when we want unpublished stuff,
    # we can pass in `with: { is_live: [true, false] }`, for
    # example.
    options[:with] ||= {}
    options[:with].reverse_merge!(published: "true")

    # -- build search query -- #

    query = { match_all:{} }

    if query_string && !query_string.empty?
      query = { query_string: { query: query_string, default_operator:"AND" } }
    end

    # what content types are we searching?
    types = options[:classes].collect(&:to_s).collect(&:underscore)

    # -- search filters -- #

    filters = []


    (options[:with]||[]).each do |k,v|
      filters << self._filter_for(k,v)
    end

    (options[:without]||[]).each do |k,v|
      filters << { not: self._filter_for(k,v) }
    end

    # -- sort -- #

    (f,dir) = options[:order].split(" ")
    sort = { f => { order: dir }}

    # -- pagination -- #

    from = 0
    per_page = (options[:per_page] || options[:limit] || 10).to_i
    if options[:page] && per_page
      from = (options[:page].to_i - 1) * per_page
    end

    # -- build search body -- #

    body = {
      query: {
        filtered: {
          query: query,
          filter: case filters.length
          when 1
            filters[0]
          else
            { and: filters }
          end
        }
      },
      sort: [ sort ],
      size: per_page,
      from: from
    }

    query body, ignore_unavailable: true, type: types
  end

  #--------------------

  def find obj_key
    class_name = obj_key.split('-').first.camelize
    ContentBase.search(classes: [class_name], limit: 1, with:{obj_key: obj_key}).first
  end

  #---------------------

  def bulk_find obj_keys
    if obj_keys[0].respond_to?(:obj_key)
      obj_keys = obj_keys.map(&:obj_key)
    end
    ContentBase.search(with: { obj_key: obj_keys }, per_page: 60)
  end

  #--------------------
  # Generate a teaser from the passed-in text.
  # If the text is blank, return an empty string.
  # If the first paragraph is <= target length, return
  # the first paragraph.
  # Otherwise get everything up to the target length,
  # the up to the next period.
  def generate_teaser(text, length=180)
    return '' if text.blank?
    teaser = ''

    stripped_body = ActionController::Base.helpers.strip_tags(text)
      .gsub("&nbsp;"," ").gsub(/\r/,'').strip

    stripped_body.match(/^.+/) do |match|
      first_paragraph = match[0]

      if first_paragraph.length <= length
        teaser = first_paragraph
      else
        shortened_paragraph = first_paragraph.match(/\A.{#{length}}[^\.]*\.?/)

        teaser = if shortened_paragraph
          "#{shortened_paragraph[0]}"
        else
          first_paragraph
        end
      end
    end

    teaser
  end


  # Safely fetch an object by a passed-in key.
  #
  # This is similar to Outpost.obj_by_key, except it only selects
  # published content and it lets us be explicit about which classes
  # to allow.
  #
  # This was originally added to make ContentMailer more safe.
  #
  # Arguments
  # * obj_key (String) - The object key to lookup.
  #
  # Examples
  #
  #   ContentBase.safe_obj_by_key("blog_entry-999") #=> #<BlogEntry...>
  #   ContentBase.safe_obj_by_key("admin_user-12") #=> nil
  def safe_obj_by_key(obj_key)
    obj = Outpost.obj_by_key(obj_key)

    if !obj || !SAFE_CLASSES.include?(obj.class.name) || !obj.published?
      return nil
    end

    obj
  end


  # safe_obj_by_key or raise error
  def safe_obj_by_key!(obj_key)
    safe_obj_by_key(obj_key) or raise ActiveRecord::RecordNotFound
  end


  #--------------------
  # Look to CONTENT_MATCHES to see if the passed-in URL
  # corresponds to any model.
  # Only find published articles.
  def obj_by_url(url)
    begin
      u = URI.parse(url)
    rescue URI::InvalidURIError
      return nil
    end

    if match = CONTENT_MATCHES.find { |k,_| u.path =~ k }
      # build the obj_key
      key       = match[1].constantize.obj_key($~[1])
      article = ContentBase.search(with:{obj_key:key}).first

    else
      nil
    end
  end

  #---------------------
  # obj_by_url or raise
  def obj_by_url!(url)
    obj_by_url(url) or raise ActiveRecord::RecordNotFound, url
  end
end # ContentBase
