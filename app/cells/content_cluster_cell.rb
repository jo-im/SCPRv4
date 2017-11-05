class ContentClusterCell < Cell::ViewModel
  def show
    render
  end

  def title(feature)
    feature.try(:title) || feature.try(:short_headline)
  end
end
