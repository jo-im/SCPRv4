class FeaturedQuoteCell < Cell::ViewModel
  property :text
  property :source_name
  property :source_context
  property :article

  def show
    render if model
  end

end
