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

  def byline_link object
    original_object = object.try(:original_object) || object
    return "KPCC" if !original_object.respond_to?(:joined_bylines)
    elements = original_object.joined_bylines do |bylines|
      bylines.map do |byline|
        if byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    ContentByline.digest(elements).html_safe
  end

end
