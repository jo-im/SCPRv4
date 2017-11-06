class ArticleHeadlineCell < Cell::ViewModel
  property :category

  cache :show do
    if @options[:preview] != true
      model.try(:cache_key)
    end
  end

  def show
    render
  end

  def title
    model.try(:title) || model.try(:headline)
  end

end
