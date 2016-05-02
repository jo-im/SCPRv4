class HomepageOptIn

  def initialize app
    @app = app
  end

  def call env
    request = ActionDispatch::Request.new(env)

    if true #request.cookie_jar.signed[:beta_opt_in]
      change_named_route :root, controller: 'better_homepage'
    end

    @app.call env
  end

  private

  def change_named_route name, controller:nil, action:nil
    routes = Rails.application.routes.routes
    if route = routes.named_routes[name.to_s]
      if controller
        route.defaults[:controller] = controller.to_s
      end
      if action
        route.defaults[:action]     = action.to_s
      end
    end
  end

end