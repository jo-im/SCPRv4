class EditionsController < ApplicationController
  respond_to :html
  before_filter :get_popular_articles

  def archive
    year = params[:year]
    month = params[:month]
    day = params[:day]

    redirect_to "/short-list/#{year}/#{month}/#{day}"
  end

  def latest
    if params[:year] and params[:month] and params[:day]
      date = Time.zone.local(
        params[:year].to_i,
        params[:month].to_i,
        params[:day].to_i
      )

      # Only fetch content if the requested date is before today's date
      if date < Time.zone.now.to_date
        @date = date
      end
    end

    if @date
      condition = [
        "published_at between :today and :tomorrow",
        :today      => @date,
        :tomorrow   => @date.tomorrow
      ]
      @latest_editions = Edition.published.includes(:slots).where(condition).first(5)
    else
      @latest_editions = Edition.published.includes(:slots).first(5)
    end

    @edition = @latest_editions.first
    @other_editions = @latest_editions - [@edition]
  end

  def short_list
    @edition = Edition.published.includes(:slots).find(params[:id])
    @other_editions = @edition.sister_editions
  end

end
