class MeetTheTeamCell < Cell::ViewModel

  def show
    render
  end

  def team
    @options[:team_heading] || "Meet #{model.try(:title)}'s team"
  end

  def bios
    model.try(:reporters) || model || []
  end

end
