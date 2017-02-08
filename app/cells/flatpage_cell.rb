class FlatpageCell < Cell::ViewModel
  def show
    render
  end

  def render_body options={}
    doc = Nokogiri::HTML(model.content.html_safe)
    order_body doc
    doc.css("body").children.to_s.html_safe
  end

  def order_body doc
    i   = 0
    doc.css("body > *").each do |element|
      element['style'] ||= ""
      unless element['style'].scan(/order:\s(.*);/).any?
        element['style'] = "#{element['style']}order:#{i};"
        element['class'] = "#{element['class']} o-flatpage o-flatpage--#{model.template}"
      end
      i += 1
    end
  end
end
