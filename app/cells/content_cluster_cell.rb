class ContentClusterCell < Cell::ViewModel
  cache :show do
    @options[:cache_key]
  end

  def show
    render
  end

  def title(feature)
    feature.try(:title) || feature.try(:short_headline)
  end
end
