class EpilogueCell < Cell::ViewModel
  include Orderable

  cache :show do
    model.try(:cache_key)
  end

  def show
    render
  end

  def category
    model.try(:category).try(:title)
  end
end
