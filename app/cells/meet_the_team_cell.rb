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

  def headshot bio
    if bio.try(:headshot)
      bio.headshot.small.url
    end
  end

end
