class Outpost::ShowSegmentsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :show
    l.column :byline
    l.column :audio
    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status, display: :display_article_status
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :show_id, collection: -> { KpccProgram.select_collection }
    l.filter :bylines, collection: -> { Bio.select_collection }
    l.filter :status, collection: -> { ShowSegment.status_select_collection }
  end

  #----------------

  def preview
    @segment = Outpost.obj_by_key(params[:obj_key]) || ShowSegment.new
    @article = @segment.get_article
    @episode = @segment.episode
    @program = @kpcc_program = @segment.show

    with_rollback @segment do
      @segment.assign_attributes(params[:show_segment])
      @segment.update_inline_assets
      if @segment.unconditionally_valid?
        @title = @segment.to_title
        render "programs/kpcc/_segment_preview",
          :layout => "outpost/preview/application",
          :locals => {
            :segment => @segment
          }
      else
        render_preview_validation_errors(@segment)
      end
    end
  end
end
