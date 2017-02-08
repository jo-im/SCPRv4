class FeaturedInteractiveCell < Cell::ViewModel
  property :short_title
  property :byline
  property :public_path

  def show
    render
  end

end
