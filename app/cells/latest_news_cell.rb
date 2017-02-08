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
    render
  end

  def media_type
    model.try(:feature).try(:name).try(:downcase)
  end

  def asset_path(resource)
    resource.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

end