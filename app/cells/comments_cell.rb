class CommentsCell < Cell::ViewModel
  include Orderable

  cache :show do
    model.try(:cache_key)
  end

  def show
    if has_comments?
      render
    end
  end

  def has_comments?
    model.respond_to?(:disqus_identifier)
  end

end
