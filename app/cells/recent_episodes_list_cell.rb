class RecentEpisodesListCell < Cell::ViewModel
  def show
    render
  end

  def asset_path(episode)
    episode.try(:asset).try(:small).try(:url) || "/static/images/fallback-img-rect.png"
  end

  def program
    @options[:program]
  end

  def format_date time, format=:long, blank_message="&nbsp;"
    time.blank? ? blank_message : time.to_s(format)
  end

  def horizontal
    render
  end

end
