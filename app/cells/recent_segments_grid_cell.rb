class RecentSegmentsGridCell < Cell::ViewModel

  def show
    render
  end

  def segments
    model.try(:segments).order("published_at DESC").try(:limit, 14)
  end

  def thumbnail_url segment
    segment.asset.square.url
  rescue
    '/static/images/fallback-img-square.png'
  end

end

