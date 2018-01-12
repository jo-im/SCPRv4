class EventCell < Cell::ViewModel
  property :assets
  property :asset

  def hero_asset(figure_class)
    if model.try(:asset_display) == :hidden || model.try(:asset_display) == "hidden" || assets.try(:empty?)
      nil
    else
      if model.try(:asset_display) == :slideshow || model.try(:asset_display) == "slideshow"
        AssetCell.new(asset, article: model, class: figure_class, template: "default/slideshow.html", featured: true).call(:show)
      else
        AssetCell.new(asset, article: model, class: figure_class, featured: true).call(:show)
      end
    end
  end

  def render_body options={}
    starts_at = model.try(:starts_at)
    ends_at = model.try(:ends_at)

    if ends_at
      original_time = ends_at
    else
      original_time = starts_at
    end

    if original_time.try(:past?) && !model.try(:archive_description).try(:empty?)
      doc = Nokogiri::HTML(model.archive_description.html_safe)
    else
      doc = Nokogiri::HTML(model.body.html_safe)
    end

    cssPath = "img.inline-asset[data-asset-id]"
    context = options[:context] || "news"
    display = options[:display] || "inline"
    doc.css(cssPath).each do |placeholder|
      asset_id = placeholder.attribute('data-asset-id').value
      asset_id = asset_id ? asset_id.to_i : nil
      next if asset_id.nil?

      # we have to fall back to original_object here to get the full list of
      # assets. in any case where we're rendering a body, we'll already have
      # the original object loaded, so that's ok
      asset = model.try(:assets).select{|a| a.asset_id == asset_id}[0]

      ## If kpcc_only is true, only render if the owner of the asset is KPCC
      if asset && (!options[:kpcc_only] || asset.owner.try(:include?, "KPCC"))
        if (asset.small.width.to_i < asset.small.height.to_i)
          if placeholder.attribute('data-align').try(:value).try(:match, /left/i)
            positioning = "o-article__body--float-left"
          else
            positioning = "o-article__body--float-right"
          end
        end
        rendered_asset = AssetCell.new(asset, context: context, display: display, article: model, class: positioning).call(:show)
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse(rendered_asset)
      else
        # FIXME: I'm sure there's a cleaner "delete"
        placeholder.replace Nokogiri::HTML::DocumentFragment.parse("")
      end
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

  def date(event)
    starts_at = event.try(:starts_at)
    ends_at = event.try(:ends_at)
    ends_at_strftime = "- %A, %B %e, %Y, %l:%M%P"
    same_day = false
    if starts_at.try(:yday) == ends_at.try(:yday) && starts_at.try(:year) == ends_at.try(:year)
      ends_at_strftime = "- %l:%M%P"
      same_day = true
    end

    if event.try(:is_all_day)
      if same_day == true
        starts_at.try(:strftime, "%A, %B %e, %Y")
      elsif ends_at
        "#{starts_at.try(:strftime, "%A, %B %e, %Y")} #{ends_at.try(:strftime, "- %A, %B %e, %Y")}"
      else
        starts_at.try(:strftime, "%A, %B %e, %Y")
      end
    elsif ends_at
      "#{starts_at.try(:strftime, "%A, %B %e, %Y, %l:%M%P")} #{ends_at.try(:strftime, ends_at_strftime)}"
    else
      starts_at.try(:strftime, "%A, %B %e, %Y, %l:%M%P")
    end
  end

  def orientation
    if model.try(:rsvp_url).try(:empty?)
      'o-event__RSVP--column'
    else
      'o-event__RSVP--row'
    end
  end
end