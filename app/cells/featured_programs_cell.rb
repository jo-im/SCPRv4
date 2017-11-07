class FeaturedProgramsCell < Cell::ViewModel

  cache :show do
    model.try(:cache_key)
  end

  def show
    render
  end

  def format_date time, format=:long, blank_message="&nbsp;"
    time.blank? ? blank_message : time.to_s(format)
  end

  def program_title
    model.try(:title)
  end

  def featured_programs
    @featured_programs ||= KpccProgram.where(is_featured: true).limit(4)
  end

end
