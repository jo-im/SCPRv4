class ShortListCell < Cell::ViewModel
  def show
    render
  end

  def featured_image
    render
  end

  def side_bar
    render
  end

  def asset_path abstract
    abstract.try(:asset).try(:full).try(:url) || "/static/images/fallback-img-rect.png"
  end

end
