class NewsletterAppealCell < Cell::ViewModel
  include Orderable

  cache :show do
    model.try(:cache_key)
  end

  def show
    render
  end

end
