class FeaturedInteractiveCell < Cell::ViewModel
  property :short_title
  property :byline
  property :public_path

  def show
    render
  end

  def byline links=true
    original_object = model.try(:original_object) || model
    return "KPCC" if !original_object.respond_to?(:joined_bylines)
    elements = original_object.joined_bylines do |bylines|
      bylines.map do |byline|
        if links && byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    ContentByline.digest(elements).html_safe
  end

end
