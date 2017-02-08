class BiographyCell < Cell::ViewModel
  def show
    render
  end

  def headshot
    render
  end

  def twitter_profile_url handle
    "https://twitter.com/#{handle.parameterize}"
  end

  def bylines
    @options[:bylines]
  end

end
