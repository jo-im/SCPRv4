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

  def asset_path(resource)
    asset_display = resource.try(:asset_display)
    assets = resource.try(:assets)
    if asset_display == :hidden || asset_display == "hidden" || assets.try(:empty?)
      nil
    else
      resource.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
    end
  end

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)
    ends_at_strftime = "- %B %e, %Y, %l:%M%P"
    same_day = false
    if starts_at.try(:yday) == ends_at.try(:yday) && starts_at.try(:year) == ends_at.try(:year)
      ends_at_strftime = "- %l:%M%P"
      same_day = true
    end

    if ends_at
      if ends_at.try(:past?)
        return 'Past Event'
      end
    elsif starts_at.try(:past?) && !event.try(:is_all_day)
      return 'Past Event'
    end

    if event.try(:is_all_day)
      if same_day == true
        starts_at.try(:strftime, "%B %e, %Y")
      elsif ends_at
        "#{starts_at.try(:strftime, "%B %e, %Y")} #{ends_at.try(:strftime, "- %B %e, %Y")}"
      else
        starts_at.try(:strftime, "%B %e, %Y")
      end
    elsif ends_at
      "#{starts_at.try(:strftime, "%B %e, %Y, %l:%M%P")} #{ends_at.try(:strftime, ends_at_strftime)}"
    else
      starts_at.try(:strftime, "%B %e, %Y, %l:%M%P")
    end
  end

end