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
    @homepage         = (HomeBase.current || Missing)
    @content          = @homepage.content
  end

  private

  def generate_homepage
    Job::BetterHomepageCache.perform
  end
end
