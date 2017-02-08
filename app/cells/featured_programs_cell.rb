class FeaturedProgramsCell < Cell::ViewModel
  def show
    render
  end

  def format_date time, format=:long, blank_message="&nbsp;"
    time.blank? ? blank_message : time.to_s(format)
  end

  def program_title
    model.title
  end

  def featured_programs
    @featured_programs ||= KpccProgram.where(is_featured: true).limit(4)
  end

end
