class MoreFromEpisodeCell < Cell::ViewModel
  include Orderable

  cache :show, expires_in: 10.minutes, :if => lambda { !@options[:preview] }  do
    [model.try(:cache_key), 'v2']
  end

  property :show
  property :headline
  property :public_path

  def show
    render if model.try(:present?)
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
    @episode_content ||= model.try(:related_content) || []
  end

end