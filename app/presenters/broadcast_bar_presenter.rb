class BroadcastBarPresenter < ScheduleOccurrencePresenter
  def show_modal?
    return false if !program.respond_to?(:is_episodic)
    !!program.try(:is_episodic)
  end

  def is_for_featured_program?
    return false if !program.respond_to?(:is_featured?)
    !!program.try(:is_featured?)
  end

  def modal_class
    "modal-toggler" if show_modal?
  end

  def toggler_id
    "episode-guide" if show_modal?
  end

  def headshot_class
    "with-headshot" if program && is_for_featured_program?
  end
end
