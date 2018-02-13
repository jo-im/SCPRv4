class AppealCell < Cell::ViewModel
  def newsletter
    render
  end

  def ipad
    render
  end

  def podcast
    render if has_podcast_links
  end

  def has_podcast_links
    present model, ProgramPresenter do |p|
      if !p.podcast_link.blank? || !p.rss_link.blank?
        return true
      else
        return false
      end
    end
  end

  def breaking_news
    render
  end

  def in_person_newsletter
    render
  end

  def editions
    render
  end

  def order
    @options[:order] || "1000"
  end

  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

end
