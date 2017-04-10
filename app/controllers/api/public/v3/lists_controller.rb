module Api::Public::V3
  class ListsController < BaseController

    def index
      if params[:context]
        @lists = List.visible.where(context: params[:context])
      else
        @lists = List.visible
      end
      respond_with @lists
    end

    def show
      @list       = List.visible.where(id: params[:id]).first!
      @list_items = @list.items.map(&:item).map(&:get_article)
      respond_with @list_items
    end

  end
end
