class NewsletterAppealCell < Cell::ViewModel
  include Orderable

  cache :show do
    if @options[:preview] != true
      model.try(:cache_key)
    end
  end

  def show
    render
  end

end
