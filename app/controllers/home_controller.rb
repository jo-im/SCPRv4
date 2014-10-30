class HomeController < ApplicationController
  layout "homepage"

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
    @homepage         = Homepage.published.first
    @featured_comment = FeaturedComment.published.includes(:content).first

    @latest_edition  = Edition.published.recently.includes(:slots).first

    @schedule_current = ScheduleOccurrence.on_at(Time.zone.now)

    if @schedule_current
      @schedule_next = @schedule_current.following_occurrence
    else
      @schedule_next = ScheduleOccurrence.after(Time.zone.now).first
    end
  end

  #----------

  def about_us
    render layout: "app_nosidebar"
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
    Job::HomepageCache.perform
  end
end
