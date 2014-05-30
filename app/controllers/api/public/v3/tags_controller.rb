module Api::Public::V3
  class TagsController < BaseController
    before_filter :sanitize_slug, only: [:show]

    def index
      @tags = Tag.all
      respond_with @tags
    end


    def show
      @tag = Tag.where(slug: @slug).first

      if !@tag
        render_not_found and return false
      end

      respond_with @tag
    end
  end
end
