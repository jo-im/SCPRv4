class BlogIndexCell < Cell::ViewModel
  def show
    render
  end

  def asset_path(blog)
    blog.latest_entry.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-square.png"
  end

end
