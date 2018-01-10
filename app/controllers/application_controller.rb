class ApplicationController < ActionController::Base
  include Outpost::Controller::CustomErrors

  protect_from_forgery
  before_filter :add_params_for_newrelic

  def add_params_for_newrelic
    NewRelic::Agent.add_custom_attributes(
      :request_referer => request.referer,
      :agent           => request.env['HTTP_USER_AGENT']
    )
  end

  #----------

  private

  def get_popular_articles
    @popular_articles = Cache.read("popular/viewed")
  end

  #----------
  # Override this method from CustomErrors to set the template prefix
  def render_error(status, e=StandardError, template_prefix="")
    super
    report_error(e)
  end
end
