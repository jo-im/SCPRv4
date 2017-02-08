class EventCell < Cell::ViewModel
  property :asset

  def hero_asset
    AssetCell.new(asset, article: model).call(:show)
  end

  def render_body options={}
    doc = Nokogiri::HTML(model.body.html_safe)
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
        element['class'] = "#{element['class']} o-event__body"
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

    if event.try(:is_all_day)
      starts_at.try(:strftime, "%A, %B %e")
    elsif ends_at
      "#{starts_at.try(:strftime, "%A, %B %e, %l:%M%P")} - #{ends_at.try(:strftime, "%l:%M%P")}"
    else
      starts_at.try(:strftime, "%A, %B %e, %l:%M%P")
    end
  end
end
