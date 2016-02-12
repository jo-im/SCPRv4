class Outpost::PledgeDrivesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "starts_at"
    l.default_order_direction   = ASCENDING

    l.column :id
    l.column :starts_at,
      :sortable                   => true,
      :default_order_direction    => ASCENDING
    l.column :ends_at,
      :sortable => true,
      :default_order_direction => ASCENDING
    l.column :created_at,
      :sortable => true,
      :default_order_direction => ASCENDING
    l.column :updated_at,
      :sortable => true,
      :default_order_direction => ASCENDING
  end

end