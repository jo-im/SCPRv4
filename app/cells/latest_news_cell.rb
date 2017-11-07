class LatestNewsCell < Cell::ViewModel
  def show
    render
  end

  def featured
    render
  end

  def top
    @options[:top]
  end

  def sections
    @options[:sections]
  end

  def categories
    render if model.try(:any?)
  end

  def media_type
    model.try(:feature).try(:name).try(:downcase)
  end

  def asset_path(resource)
    resource.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def byline object
    original_object = object.try(:original_object) || object
    return "KPCC" if !original_object.respond_to?(:joined_bylines)
    elements = original_object.joined_bylines do |bylines|
      bylines.map do |byline|
        if byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    ContentByline.digest(elements).html_safe
  end

end