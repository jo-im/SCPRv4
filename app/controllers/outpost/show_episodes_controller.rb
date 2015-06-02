class Outpost::ShowEpisodesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "air_date"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :show
    l.column :air_date,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status
    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :show_id, collection: -> { KpccProgram.select_collection }
    l.filter :status, collection: -> { ShowEpisode.status_select_collection }
  end


  def preview
    @episode = Outpost.obj_by_key(params[:obj_key]) || ShowEpisode.new
    @episodes = []
    
    with_rollback @episode do
      @episode.assign_attributes(params[:show_episode])

      if @episode.unconditionally_valid?
        @title = @episode.to_title

        if @episode.show.is_segmented?
          @segments = @episode.segments
          @program = @episode.show

          render "programs/kpcc/episode",
            :layout => "outpost/preview/application"
        else
          render "programs/kpcc/_episode",
            :layout => "outpost/preview/application",
            :locals => {
              :episode => @episode
            }
        end
      else
        render_preview_validation_errors(@episode)
      end
    end
  end
end
