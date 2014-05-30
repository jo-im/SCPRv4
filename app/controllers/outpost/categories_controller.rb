class Outpost::CategoriesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title, sortable: true
    l.column :slug, sortable: true
    l.column :comment_bucket
  end
end
