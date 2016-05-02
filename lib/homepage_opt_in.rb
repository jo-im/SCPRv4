class HomepageOptIn

  def initialize app
    @app = app
  end

  def call env
    request = ActionDispatch::Request.new(env)
    if request.cookie_jar[:beta_opt_in]
      change_named_route :root, controller: 'better_homepage'
    else
      change_named_route :root, controller: 'home'
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