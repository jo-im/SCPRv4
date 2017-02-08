class SearchCell < Cell::ViewModel
  def show
    render
  end

  def programs
    KpccProgram.active.order("title") + ExternalProgram.active.order("title")
  end
end
