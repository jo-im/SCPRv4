class CommentsCell < Cell::ViewModel
  include Orderable

  def show
    if has_comments?
      render
    end
  end

  def has_comments?
    model.respond_to?(:disqus_identifier)
  end

end
