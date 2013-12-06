class NewApplicationController < ActionController::Base
  include Outpost::Controller::CustomErrors

  protect_from_forgery
  before_filter :add_params_for_newrelic


  private

  def add_params_for_newrelic
    NewRelic::Agent.add_custom_parameters(
      :request_referer => request.referer,
      :agent           => request.env['HTTP_USER_AGENT']
    )
  end

  def get_popular_articles
    # We have to rescue here because Marshal doesn't know about
    # Rails' autoloading. This should be a non-issue in production,
    # but just in case (and for development), we should be safe.
    # This is fixed in Rails 4.
    # https://github.com/rails/rails/issues/8167
    prev_klass = nil

    begin
      @popular_articles = Rails.cache.read("popular/viewed")
    rescue ArgumentError => e
      klass = e.message.match(/undefined class\/module (.+)\z/)[1]

      # If we already tried to load this class but couldn't,
      # give up.
      if klass == prev_klass
        @popular_articles = nil
        return
      end

      prev_klass = klass
      klass.constantize # Let Rails load it for us.
      retry
    end
  end


  # Override this method from CustomErrors to set the layout
  def render_error(status, e=StandardError)
    super
    report_error(e)
  end
end
