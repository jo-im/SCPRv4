module Api::Public::V3
  class ListsController < BaseController

    def index
      if params[:context]
        @lists = List.visible
          .where(context: params[:context])
          .order('position ASC')
      else
        @lists = List.visible
          .order('position ASC')
      end
      respond_with @lists
    end

    def show
      @list       = List.visible.where(id: params[:id]).first!
      @list_items = @list.items.articles
      respond_with @list_items
    end

  end
end
