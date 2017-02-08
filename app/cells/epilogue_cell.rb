class EpilogueCell < Cell::ViewModel
  include Orderable

  def show
    render
  end

  def category
    model.try(:category).try(:title)
  end
end
