class ArchivePickerCell < Cell::ViewModel
  include Orderable
  property :title
  property :slug

  def show
    render
  end

end
