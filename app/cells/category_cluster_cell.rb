class CategoryClusterCell < Cell::ViewModel
  include Orderable

  property :title
  property :slug
  property :public_path

  def show &block
    if content.any?
      (render + (block_given? ? yield : "")).html_safe
    end
  end

  def content
    @content ||= (model.try(:content) || []).map{ |a| a.get_article }.first(3)
  end

end
