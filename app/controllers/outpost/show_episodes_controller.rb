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
end
