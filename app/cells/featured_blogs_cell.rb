class FeaturedBlogsCell < Cell::ViewModel
  def show
    render
  end

  def format_date time, format=:long, blank_message="&nbsp;"
    time.blank? ? blank_message : time.to_s(format)
  end

  def blog_title
    @options[:blog]
  end

  def featured_blogs
    @featured_blogs ||= model
  end

end
