class ArticleHeadlineCell < Cell::ViewModel
  property :category
  property :title

  cache :show do
    model.try(:cache_key)
  end

  def show
    render
  end

end
