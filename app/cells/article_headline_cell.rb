class ArticleHeadlineCell < Cell::ViewModel
  property :category

  cache :show, expires_in: 10.minutes, :if => lambda { !@options[:preview] }  do
    [model.try(:cache_key), 'v2']
  end

  def show
    render
  end

  def title
    model.try(:title) || model.try(:headline)
  end

end
