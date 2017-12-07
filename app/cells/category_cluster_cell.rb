class CategoryClusterCell < Cell::ViewModel
  include Orderable

  cache :show do
    model.try(:cache_key)
  end

  property :title
  property :slug
  property :public_path

  def show &block
    if content.any?
      (render + (block_given? ? yield : "")).html_safe
    end
  end

  def content
    @content ||= (model.try(:content) || []).try(:first, 3)
  end

end
