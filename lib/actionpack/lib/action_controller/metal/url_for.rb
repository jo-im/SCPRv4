## This is a monkeypatch to fix this problem:
## https://github.com/rails/rails/issues/20738
## As of Rails 5.0.0, the problem still has not
## been addressed.  It causes the root route to
## change for a mounted Rails engine when navigated
## to a deeper route, causing some things like
## the login/logout route to be incorrect in Outpost.

module ActionController

  module UrlFor
    extend ActiveSupport::Concern

    include AbstractController::UrlFor

    def url_options
      @_url_options ||= {
        :host     => request.host,
        :port     => request.optional_port,
        :protocol => request.protocol,
        :_recall  => request.path_parameters
      }.merge!(super).freeze

      same_origin = _routes.equal?(env["action_dispatch.routes".freeze])
      script_name = env["ROUTES_#{_routes.object_id}_SCRIPT_NAME"]
      original_script_name = env['ORIGINAL_SCRIPT_NAME'.freeze]

      if same_origin || script_name || original_script_name

        options = @_url_options.dup

        unless original_script_name.to_s.empty?
          options[:original_script_name] = original_script_name
          options
        else
          if same_origin
            unless script_name.to_s.empty?
              options[:script_name] = script_name
            else
              options[:script_name] = request.script_name.empty? ? "".freeze : request.script_name.dup
            end
          else
            options[:script_name] = script_name
          end
          options.freeze
        end

      else
        @_url_options
      end
    end

  end
  
end