class Outpost::ShowEpisodesController < Outpost::ResourceController
  outpost_controller
  include Concern::Controller::ShowEpisodes

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

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :show_id, collection: -> { KpccProgram.select_collection }
    l.filter :status, collection: -> { ShowEpisode.status_select_collection }
  end

  def preview
    @episode = Outpost.obj_by_key(params[:obj_key]) || ShowEpisode.new

    with_rollback @episode do
      @episode.assign_attributes(params[:show_episode])
      @episode.update_inline_assets
      if @episode.unconditionally_valid?
        @program = @episode.show
        render_kpcc_episode
      else
        render_preview_validation_errors @episode
      end
    end
  end

end
