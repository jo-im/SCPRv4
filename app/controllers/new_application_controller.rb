class NewApplicationController < ActionController::Base
  include Outpost::Controller::CustomErrors
  include GetPopularArticles

  protect_from_forgery
  before_filter :add_params_for_newrelic


  private

  def add_params_for_newrelic
    NewRelic::Agent.add_custom_parameters(
      :request_referer => request.referer,
      :agent           => request.env['HTTP_USER_AGENT']
    )
  end

  # Override this method from CustomErrors to set the layout
  def render_error(status, e=StandardError)
    super
    report_error(e)
  end
end
