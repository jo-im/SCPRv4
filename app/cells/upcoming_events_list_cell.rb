class UpcomingEventsListCell < Cell::ViewModel
  def show
    render
  end

  def asset_aspect
    @options[:asset_aspect] || "square"
  end

  def tabs
    render
  end

  def tab
    @options[:tab]
  end

  def asset_path(article)
     article.try(:asset).try(:small).try(:url) || '/static/images/fallback-img-rect.png'
  end

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)

    if starts_at.try(:past?)
      'Past Event'
    else
      if event.try(:is_all_day)
        starts_at.try(:strftime, "%A, %B %e")
      elsif ends_at
        "#{starts_at.try(:strftime, "%A, %B %e, %l:%M%P")} - #{ends_at.try(:strftime, "%l:%M%P")}"
      else
        starts_at.try(:strftime, "%A, %B %e, %l:%M%P")
      end
    end
  end
end