class ResourcesCell < Cell::ViewModel
  property :title

  def show
    render
  end

  def asset_path(article)
    article.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def articles
    model.featured_articles[1..4]
  end

end
