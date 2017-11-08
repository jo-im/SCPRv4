class EventCell < Cell::ViewModel
  property :asset

  def hero_asset
    AssetCell.new(asset, article: model).call(:show)
  end

  def render_body options={}
    starts_at = model.try(:starts_at)
    ends_at = model.try(:ends_at)

    if ends_at.try(:past?)
      doc = Nokogiri::HTML(model.archive_description.html_safe)
    else
      doc = Nokogiri::HTML(model.body.html_safe)
    end

    order_body doc
    doc.css("body").children.to_s.html_safe
  end

  def order_body doc
    doc.css("body > *").each_with_index do |element, i|
      if i == 0
        element['class'] = 'o-event__body__first-paragraph'
      end
      element['style'] ||= ""
      unless element['style'].scan(/order:\s(.*);/).any?
        element['style'] = "#{element['style']}order:#{i + 4};"
        element['class'] = "#{element['class']}"
      end
    end
  end

  def flex_direction
    if model.try(:rsvp_url)
      return "row"
    else
      return "column"
    end
  end

  def start_date
    if !model.try(:starts_at)
      return ''
    end

    model.try(:starts_at).strftime('%A, %B %e, %l:%M')
  end

  def end_date
    if !model.try(:ends_at)
      return ''
    end

    model.try(:ends_at).strftime('%l:%M%P')
  end

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)
    ends_at_strftime = "- %A, %B %e, %l:%M%P"
    if starts_at.try(:yday) == ends_at.try(:yday) && starts_at.try(:year) == ends_at.try(:year)
      ends_at_strftime = "- %l:%M%P"
    end

    if event.try(:is_all_day)
      starts_at.try(:strftime, "%A, %B %e")
    elsif ends_at
      "#{starts_at.try(:strftime, "%A, %B %e, %l:%M%P")} #{ends_at.try(:strftime, ends_at_strftime)}"
    end
  end
end