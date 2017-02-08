class EventListCell < Cell::ViewModel
  def show
    render
  end

  def asset_path(event)
     event.try(:asset).try(:small).try(:url) || '/static/images/fallback-img-square.png'
  end

  def asset_aspect
    @options[:asset_aspect] || "square"
  end

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)

    if event.try(:is_all_day)
      starts_at.try(:strftime, "%A, %B %e")
    elsif starts_at && ends_at
      "#{starts_at.try(:strftime, "%A, %B %e, %l:%M%P")} - #{ends_at.try(:strftime, "%l:%M%P")}"
    else
      starts_at.try(:strftime, "%A, %B %e, %l:%M%P")
    end
  end
end
