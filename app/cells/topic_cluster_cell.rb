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

  def byline object
    original_object = object.try(:original_object) || object
    return "KPCC" if !original_object.respond_to?(:joined_bylines)
    elements = original_object.joined_bylines do |bylines|
      bylines.map do |byline|
        if byline.user.try(:is_public)
          link_to byline.display_name, byline.user.public_path
        else
          byline.display_name
        end
      end
    end
    ContentByline.digest(elements).html_safe
  end

end
