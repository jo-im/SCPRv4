class MoreFromEpisodeCell < Cell::ViewModel
  include Orderable

  property :show
  property :headline
  property :public_path

  def show
    render
  end

  def headline
    model.try(:headline)
  end

  def public_path
    model.try(:public_path)
  end

  def airdate
    model.try(:air_date).try(:strftime, "%B %-d, %Y")
  end

  def show_title
    model.try(:show).try(:title)
  end

  def episode_content
    @episode_content ||= model.try(:to_article).try(:related_content) || []
    # model.segments
  end

end
