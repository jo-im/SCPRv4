class AppealCell < Cell::ViewModel
  def newsletter
    render
  end

  def ipad
    render
  end

  def podcast
    render
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
