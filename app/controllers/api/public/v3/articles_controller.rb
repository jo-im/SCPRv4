module Api::Public::V3
  class ArticlesController < BaseController
    TYPES = {
      "news"        => [NewsStory],
      "external"    => [ContentShell],
      "blogs"       => [BlogEntry],
      "segments"    => [ShowSegment]
    }

    DEFAULTS = {
      :types        => "news,blogs,segments",
      :limit        => 10,
      :page         => 1 # o, rly?
    }

    MAX_RESULTS = 40

    before_filter \
      :set_hash_conditions,
      :set_classes,
      :sanitize_limit,
      :sanitize_page,
      :sanitize_query,
      :sanitize_categories,
      :sanitize_date_range,
      :sanitize_date,
      only: [:index]

    before_filter :sanitize_obj_key, only: [:show]
    before_filter :sanitize_url, only: [:by_url]
    before_filter :sanitize_tags, only: [:index]

    #---------------------------

    def index
      @articles = Rails.cache.fetch("/api/v3/articles/#{@query}/#{@classes.map(&:name).join(',')}/#{@limit}/#{@page}/#{@conditions}", expires_in: 5.minutes) do
        articles = ContentBase.search(@query, {
          :classes => @classes,
          :limit   => @limit,
          :page    => @page,
          :with    => @conditions
        })

        # Strip out singleton methods so that rails can cache it properly
        stripped_articles = strip_singleton articles
      end

      respond_with @articles
    end

    def strip_singleton(obj)
      obj = obj.dup unless (obj.nil? || obj.singleton_methods.empty?)
      obj.instance_variables.each do |var|
        obj.instance_variable_set(var, strip_singleton(obj.instance_variable_get(var)))
      end
      obj
    end

    #---------------------------

    def by_url
      @article = ContentBase.obj_by_url(@url)

      if !@article
        render_not_found and return false
      end

      respond_with @article do |format|
        format.json { render :show }
      end
    end

    #---------------------------

    def show
      @article = ContentBase.search(with:{obj_key:@obj_key}).first

      if !@article
        render_not_found and return false
      end

      respond_with @article
    end

    #---------------------------

    def most_viewed
      @articles = Cache.read("popular/viewed")

      if !@articles
        render_service_unavailable(
          message: "Cache not warm. Try again in a few minutes."
        ) and return false
      end

      respond_with @articles do |format|
        format.json { render :index }
      end
    end

    #---------------------------

    def most_commented
      @articles = Cache.read("popular/commented")

      if !@articles
        render_service_unavailable(
          message: "Cache not warm. Try again in a few minutes."
        ) and return false
      end

      respond_with @articles do |format|
        format.json { render :index }
      end
    end

    #---------------------------

    private

    def set_classes
      @classes = []
      types = params[:types] || defaults[:types]

      types.split(",").uniq.each do |type|
        if klasses = TYPES[type]
          @classes += klasses
        end
      end

      @classes.uniq!
    end

    #---------------------------

    def sanitize_query
      @query = params[:query].to_s
    end

    #---------------------------

    def sanitize_obj_key
      @obj_key = params[:obj_key].to_s
    end

    #---------------------------

    def sanitize_url
      begin
        # Parse the URI and then turn it back into a string,
        # just to make sure it's even a valid URI before we pass
        # it on.
        @url = URI.parse(params[:url]).to_s
      rescue URI::Error
        render_bad_request(message: "Invalid URL") and return false
      end
    end

    #---------------------------

    def sanitize_categories
      return true if !params[:categories]

      slugs   = params[:categories].to_s.split(',')
      #ids     = Category.where(slug: slugs).map(&:id)

      @conditions["category.slug"] = slugs
    end


    def sanitize_tags
      return false if !params[:tags]

      slugs   = params[:tags].to_s.split(',')
      #ids     = Tag.where(slug: slugs).map(&:id)

      @conditions["tags.slug"] = slugs
    end


    def sanitize_date
      return true if !params[:date]

      begin
        date = Time.zone.parse!(params[:date])
      rescue ArgumentError
        render_bad_request(message: "Invalid Date. Format is YYYY-MM-DD.")
        return false
      end

      @conditions[:public_datetime] = date.beginning_of_day..date.end_of_day
    end


    def sanitize_date_range
      return true if !params[:start_date] && !params[:end_date]

      if params[:end_date] && !params[:start_date]
        render_bad_request(message: "start_date is required when " \
                                    "requesting a date range.")
        return false
      end

      begin
        # If no end_date was passed in, then we should assume that they wanted
        # everything from start_date to now.
        start_date = Time.zone.parse!(params[:start_date])
        end_date = params[:end_date] ? Time.zone.parse!(params[:end_date]) : Time.zone.now

      rescue ArgumentError # Time couldn't be parsed
        render_bad_request(message: "Invalid Date. Format is YYYY-MM-DD.")
        return false
      end

      @conditions[:public_datetime] =
        start_date.beginning_of_day..end_date.end_of_day
    end
  end
end
