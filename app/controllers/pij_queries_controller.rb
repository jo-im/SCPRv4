class PijQueriesController < ApplicationController
  def index
    @featured     = PijQuery.published.where(is_featured: true)
    @not_featured = PijQuery.published.where(is_featured: false)
    @evergreen    = @not_featured.where(query_type: "evergreen")
    @news         = @not_featured.where(query_type: "news")
    @past_events     = Event.kpcc_in_person.past.limit(5)
  end

  def show
    @query = PijQuery.published.find_by_slug!(params[:slug])
    @article = @query.to_article
    @past_events     = Event.kpcc_in_person.past.limit(5)
  end
end
