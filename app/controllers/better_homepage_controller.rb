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

  def index
    @homepage         = BetterHomepage.current.last
    @current_program  = ScheduleOccurrence.current.first
  end

  def opt_in
    cookies.permanent[:beta_opt_in] = "true"
    redirect_to beta_homepage_url
  end

  def opt_out
    cookies[:beta_opt_in] = nil
    redirect_to root_url
  end

  private

  def generate_homepage
    Job::BetterHomepageCache.perform
  end
end
