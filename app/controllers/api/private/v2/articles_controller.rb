module Api::Private::V2
  class ArticlesController < BaseController
    TYPES = {
      "news"        => [NewsStory],
      "shells"      => [ContentShell],
      "blogs"       => [BlogEntry],
      "segments"    => [ShowSegment],
      "episodes"    => [ShowEpisode],
      "abstracts"   => [Abstract],
      "events"      => [Event],
      "queries"     => [PijQuery]
    }

    DEFAULTS = {
      :types        => "news,blogs,segments",
      :limit        => 10,
      :order        => "public_datetime",
      :sort_mode    => DESCENDING,
      :page         => 1 # o, rly?
    }

    before_filter \
      :set_classes,
      :sanitize_limit,
      :sanitize_page,
      :sanitize_query,
      :sanitize_order,
      :sanitize_conditions,
      only: [:index]

    before_filter :sanitize_obj_key, only: [:show]
    before_filter :sanitize_url, only: [:by_url]

    #---------------------------

    def index
      @articles = ContentBase.search(@query, {
        :classes   => @classes,
        :limit     => @limit,
        :page      => @page,
        :order     => @order,
        :with      => @conditions
      })

      respond_with @articles
    end

    #---------------------------

    def by_url
      @article = ContentBase.obj_by_url(@url)

      if !@article
        render_not_found and return false
      end

      @article = @article.to_article

      respond_with @article do |format|
        format.json { render :show }
      end
    end

    #---------------------------

    def show
      @article = Outpost.obj_by_key(@obj_key)

      if !@article
        render_not_found and return false
      end

      @article = @article.to_article
      respond_with @article
    end


    #---------------------------

    private

    def set_classes
      @classes = []
      types = params[:types] || DEFAULTS[:types]

      types.split(",").uniq.each do |type|
        if klasses = TYPES[type]
          @classes += klasses
        end
      end

      @classes.uniq!
    end

    #---------------------------
    # No Limit for Private API
    def sanitize_limit
      @limit = params[:limit] ? params[:limit].to_i : DEFAULTS[:limit]
    end

    #---------------------------

    def sanitize_page
      page = params[:page].to_i
      @page = page > 0 ? page : DEFAULTS[:page]
    end

    #---------------------------

    def sanitize_query
      @query = params[:query].to_s
    end

    #---------------------------

    def sanitize_order
      order       = (params[:order] || DEFAULTS[:order]).to_s
      sort_mode   = (params[:sort_mode] || DEFAULTS[:sort_mode]).downcase

      direction =
        if [DESCENDING, ASCENDING].include?(sort_mode)
          sort_mode
        else
          DEFAULTS[:sort_mode]
        end

      @order = "#{order} #{direction}"
    end

    #---------------------------

    def sanitize_conditions
      @conditions = params[:with]
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
  end
end
