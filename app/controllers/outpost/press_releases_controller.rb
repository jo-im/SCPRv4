class Outpost::PressReleasesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "created_at"
    l.default_order_direction   = DESCENDING

    l.column :short_title
    l.column :created_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end
end
