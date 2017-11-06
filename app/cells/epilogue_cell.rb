class EpilogueCell < Cell::ViewModel
  include Orderable

  cache :show do
    if @options[:preview] != true
      model.try(:cache_key)
    end
  end

  def show
    render
  end

  def category
    model.try(:category).try(:title)
  end
end
