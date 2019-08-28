class Outpost::HomeController < Outpost::BaseController
  def dashboard
    breadcrumb "Dashboard", outpost.root_path

    # Get the latest activity
    @current_user_activities = current_user.activities
      .where("created_at > ?", 1.week.ago)
      .order("created_at desc").limit(10)

    @latest_activities = Secretary::Version.order("created_at desc")
      .where("user_id != ?", current_user.id).limit(10)
  end


  def search
    # -- pagination -- #

    from = 0
    per_page = 20
    if params[:page]
      from = (params[:page].to_i - 1) * per_page
    end

    # -- query -- #

    body = {
      query: {
        query_string: {
          query:              params[:gquery],
          default_operator:   "AND",
        }
      },
      size: per_page,
      from: from,
    }

    results = Hashie::Mash.new(Elasticsearch::Model.client.search index: ES_MODELS_INDEX, body:body)

    records = results.hits.hits.collect do |h|
      h._source.merge({
        klass:      h._type,
        created_at: Time.zone.parse(h._source.created_at),
        updated_at: Time.zone.parse(h._source.updated_at),
      })
    end

    # -- inject pagination bits into the array -- #

    records.instance_variable_set :@_pagination, Hashie::Mash.new({
      per_page:       per_page,
      offset:         from,
      total_results:  results.hits.total.value
    })

    records.singleton_class.class_eval do
      define_method :current_page do
        ( @_pagination.offset / @_pagination.per_page ).floor + 1
      end

      define_method :total_pages do
        ( @_pagination.total_results / @_pagination.per_page )
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

    @records = records
  end

  def trigger_error
    raise StandardError, "This is a test error. It works (or does it?)"
  end
end
