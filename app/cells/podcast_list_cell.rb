class PodcastListCell < Cell::ViewModel
  def show
    render
  end

  def asset_aspect
    @options[:asset_aspect] || "square"
  end
end
