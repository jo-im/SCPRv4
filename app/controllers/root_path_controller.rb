class RootPathController < ApplicationController
  include FlatpageHandler
  include VerticalHandler
  include CategoryHandler

  respond_to :html, :xml, :rss

  def handle_path
    begin
      # Rails strips out beginning and trailing slashes
      # http://scpr.org/support/members -> support/members
      path = URI.encode(params[:path].to_s)
    rescue ArgumentError
      # If you don't pass the URI.encode test,
      # then you get NOTHING.
      # http://www.youtube.com/watch?v=xKG07305CBs
      render status: :bad_request and return
    end

    if @flatpage = Flatpage.visible.find_by_path(path.downcase)
      handle_flatpage and return
    end

    # Only do the gsubbing if necessary
    slug = path.gsub(/\A\/?(.+)\/?\z/, "\\1").downcase

    if @vertical = Vertical.find_by_slug(slug)
      if request.format.html?
        # Still not entirely convinced by this...
        action = "handle_vertical_#{slug}"
        action_methods.include?(action) ? send(action) : handle_vertical_default
      else
        @category = @vertical.category
        handle_category
      end

      return
    end

    if @category = Category.find_by_slug(slug)
      handle_category and return
    end

    # If we haven't returned by now, then render a 404.
    render_error(404, ActionController::RoutingError.new("Not Found"))
    return false
  end
end
