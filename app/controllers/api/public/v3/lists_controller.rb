module Api::Public::V3
  class ListsController < BaseController

    def index
      Rails.cache.fetch('/api/v3/lists', expires_in: 5.minutes) do
        if !context.empty?
          @lists = List.visible
            .where("FIND_IN_SET(?, context)", context)
            .order('position ASC')
        else
          @lists = List.visible
            .order('position ASC')
        end
        respond_with @lists
      end
    end

    def show
      @list       = List.visible.where(id: params[:id]).first!
      @list_items = @list.items.articles

      if @list_items.empty?
        @list_items = @list.deduped_category_items
      end

      respond_with @list_items
    end

    private

    def context
      (params[:context] || "").strip
    end

  end
end
