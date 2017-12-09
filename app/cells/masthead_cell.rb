class MastheadCell < Cell::ViewModel
  cache :show, expires_in: 12.hours do
    ["masthead", "v2"]
  end

  def show
    render
  end

  def beat_tags
    Tag.where(:tag_type => 'beat').order(:title)
  end

  def featured_programs
    @featured_programs ||= (KpccProgram.where(is_featured: true) + ExternalProgram.where(is_featured: true)).try(:sort_by!) { |program| program.title }
  end
end
