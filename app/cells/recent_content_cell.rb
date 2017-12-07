class RecentContentCell < Cell::ViewModel
  include Orderable

  cache :show do
    "#{model.try(:cache_key)} #{@options[:class]}"
  end

  property :title
  property :public_path

  def show
    if recent_content.any?
      render
    end
  end

  def title
    @options[:blog] || model.try(:title)
  end

  def public_path
    model.try(:public_path)
  end

  def recent_content
    @content ||= (model.try(:segments).try(:published).try(:first, 3) || model || [])
  end

  def events
    render
  end

end
