class Outpost::ListsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 3

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end

end
