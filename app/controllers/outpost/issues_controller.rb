class Outpost::IssuesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "created_at"
    l.default_order_direction   = DESCENDING

    l.column :title,
      :sortable => true,
      :default_order_direction => ASCENDING

    l.column :slug,
      :sortable => true,
      :default_order_direction => ASCENDING

    l.column :description
    l.column :is_active

    l.column :created_at,
      :sortable => true,
      :default_order_direction => DESCENDING


    l.filter :is_active,
      :title        => "Active?",
      :collection   => :boolean
  end
end

