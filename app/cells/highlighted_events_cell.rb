class HighlightedEventsCell < Cell::ViewModel
  def show
    render
  end

  def asset_path(resource)
    resource.try(:asset).try(:eight).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)

    if starts_at.try(:past?)
      'Past Event'
    else
      if event.try(:is_all_day)
        starts_at.try(:strftime, "%A, %B %e")
      else
        "#{starts_at.try(:strftime, "%A, %B %e, %l:%M%P")} - #{ends_at.try(:strftime, "%l:%M%P")}"
      end
    end
  end

  def text_color(event)
    if event.try(:starts_at).try(:past?)
      'u-text-color--gray-warm'
    else
      'u-text-color--sec'
    end
  end
end
