class ScheduleCell < Cell::ViewModel
  def show
    render
  end

  def selected_date
    @options[:date]
  end

  def format_adjacent_date(strftime_string, direction)
    if direction == 'tomorrow'
      date = selected_date + 1.day
    elsif direction == 'yesterday'
      date = selected_date - 1.day
    end

    date.strftime(strftime_string)
  end
end
