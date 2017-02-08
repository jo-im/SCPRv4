class BetterHomepageController < ApplicationController
  layout "better_homepage"

  # Just for development purposes
  # Pass ?regenerate to the URL to regenerate the homepage category blocks
  # Only works in development
  before_filter :generate_homepage,
    :only   => :index,
    :if     => -> {
      %w{development staging}.include?(Rails.env) &&
      params.has_key?(:regenerate)
    }

  before_filter :load_schedule,
    only: :index

  def index
    @featured_programs = (KpccProgram.where(is_featured: true) + ExternalProgram.where(is_featured: true)).try(:sort_by!) { |program| program.title }
    @beat_tags = Tag.where(:tag_type => 'beat').order(:title)
  end

  private

  def load_schedule
    # Load a collapsed schedule for the next 8 hours
    @schedule = ScheduleOccurrence.block(
      (Time.zone.now - 8.hours), 16.hours, true
    ).reject { |o| o.ends_at < Time.zone.now }

    if !@schedule.any?
      @schedule_current = Missing
      @schedule_next    = Missing
    elsif @schedule[0].starts_at < Time.zone.now
      @schedule_current = @schedule[0]
      @schedule_next    = @schedule[1] || Missing
    else
      @schedule_current = Missing
      @schedule_next    = @schedule[0]
    end
  end

  def generate_homepage
    Job::BetterHomepageCache.perform
  end
end
