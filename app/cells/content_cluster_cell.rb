class ContentClusterCell < Cell::ViewModel
  def show
    render
  end

  def title
    model.try(:title)
  end
end
