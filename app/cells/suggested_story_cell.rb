class SuggestedStoryCell < Cell::ViewModel

  property :teaser
  property :short_title
  property :public_path

  def show
    render
  end

  def program_title
    model.try(:show).try(:title) || "this series"
  end

  def asset_path
    model.try(:asset).try(:full).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def timestamp
    datetime = model.try(:public_datetime)
    if datetime
      "<time class=\"o-suggested-story__datetime\" datetime=\"#{datetime.try(:iso8601)}\">" +
        datetime.try(:strftime, "%B %-d, %Y") +
      "</time>"
    end
  end

end
