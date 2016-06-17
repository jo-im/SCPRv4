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
    @homepage         = (HomeBase.current || BetterHomepage.order('published_at DESC').limit(1).first.try(:to_indexable) || Missing)
    @content          = @homepage.content
    @current_program  = ScheduleOccurrence.current.first
  end

  def opt_in
    cookies.permanent[:beta_opt_in] = "true"
    redirect_to root_url
  end

  private

  def generate_homepage
    Job::BetterHomepageCache.perform
  end
end
