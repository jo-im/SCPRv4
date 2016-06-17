class Outpost::MissedItBucketsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :id
    l.column :title,
      :sortable                   => true,
      :default_order_direction    => ASCENDING

    l.column :slug
  end
end
