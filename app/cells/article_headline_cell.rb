class ArticleHeadlineCell < Cell::ViewModel
  property :category

  cache :show, :if => lambda { !@options[:preview] } do
    model.try(:cache_key)
  end

  def show
    render
  end

  def title
    model.try(:title) || model.try(:headline)
  end

end
