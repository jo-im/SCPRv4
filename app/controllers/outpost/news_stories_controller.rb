class Outpost::NewsStoriesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :byline
    l.column :audio
    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status, display: :display_article_status
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :status, collection: -> { NewsStory.status_select_collection }
    l.filter :bylines, collection: -> { Bio.select_collection }
  end

  #----------------

  def preview
    @entry = Outpost.obj_by_key(params[:obj_key]) || NewsStory.new

    with_rollback @entry do
      @entry.assign_attributes(params[:news_story])

      if @entry.unconditionally_valid?
        @title = @entry.to_title
        render "news/_story",
          :layout => "outpost/preview/new/application",
          :locals => {
            :story => @entry
          }
      else
        render_preview_validation_errors(@entry)
      end
    end
  end
end
