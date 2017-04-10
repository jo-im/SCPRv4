module Api::Public::V3
  class ListsController < BaseController

    def index
      if params[:context]
        @lists = List.published.where(context: params[:context])
      else
        @lists = List.published
      end
      respond_with @lists
    end

    def show
      @list = List.published.where(id: params[:id]).first!
      respond_with @list
    end

  end
end
