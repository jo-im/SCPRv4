class ProgramListCell < Cell::ViewModel
  def show
    render
  end

  def featured
    render
  end

  def asset_aspect
    @options[:asset_aspect] || "square"
  end
end
