class HomeController < ApplicationController

  # Just for development purposes
  # Pass ?regenerate to the URL to regenerate the homepage category blocks
  # Only works in development
  before_filter :generate_homepage,
    :only   => :index,
    :if     => -> {
      %w{development staging}.include?(Rails.env) &&
      params.has_key?(:regenerate)
    }

  def index
    if cookies[:beta_opt_in] == "true"
      redirect_to beta_homepage_url
    else
      @homepage         = Homepage.published.first
      @featured_comment = FeaturedComment.published.includes(:content).first

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
  end

  #----------

  def about_us
    render "about_us"
  end

  def not_found
    render_error(404, ActionController::RoutingError.new("Not Found"))
  end

  def trigger_error
    raise StandardError, "This is a test error. It works (or does it?)"
  end

  #----------

  def missed_it_content
    @homepage = Homepage.includes(:missed_it_bucket).find(params[:id])

    # This action shouldn't be called if there isn't a missed it bucket.
    # But just in case, to avoid errors...
    if !@homepage.missed_it_bucket
      render text: "", status: :not_found and return
    end

    @carousel_contents = @homepage.missed_it_bucket
      .content.includes(:content).page(params[:page]).per(6)

    render 'missed_it_content', formats: [:js]
  end


  private

  def generate_homepage
    Job::BetterHomepageCache.perform
  end
end
