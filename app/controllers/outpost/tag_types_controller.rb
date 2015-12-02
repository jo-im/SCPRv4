class Outpost::TagTypesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "name"
    l.default_order_direction   = ASCENDING

    l.column :name,
      :sortable => true,
      :default_order_direction => ASCENDING

    l.column :tag_count,
      :sortable => false
  end
end
