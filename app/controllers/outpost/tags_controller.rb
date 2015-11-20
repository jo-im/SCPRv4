class Outpost::TagsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title,
      :sortable => true,
      :default_order_direction => ASCENDING

    l.column :slug,
      :sortable => true,
      :default_order_direction => ASCENDING

    l.column :description
    l.column :is_featured, header: "Featured?"

    l.column :created_at,
      :sortable => true,
      :default_order_direction => DESCENDING

  end
end
