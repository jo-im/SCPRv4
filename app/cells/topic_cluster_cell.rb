class TopicClusterCell < Cell::ViewModel
  include Orderable

  property :title
  property :slug
  property :public_url
  property :featured_content

  def show &block
    # Tags that come straight from an Article are
    # not loaded directly from the tags table, so
    # we have to search it out so we can have find
    # featured content.
    return if !model || !content || !content.try(:any?)
    (render + (block_given? ? yield : "")).html_safe
  end

  def vertical
    return if !model || !content || !content.try(:any?)
    render
  end

  def tag
    if !model.id
      @tag ||= Tag.where(slug: model.slug).first
    else
      model
    end
  end

  def content
    tag.try(:featured_content)[1..2]
  end

end
