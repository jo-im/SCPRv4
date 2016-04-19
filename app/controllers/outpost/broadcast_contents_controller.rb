class Outpost::BroadcastContentsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :title
    l.column :audio

    # l.column :published_to_pmp?, display: :display_pmp_status
  end

end
