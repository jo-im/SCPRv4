class ListenLiveCell < Cell::ViewModel
  def show
    render
  end

  def latest_edition
    @options[:latest_edition]
  end
end