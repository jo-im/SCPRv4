class Outpost::QuotesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "created_at"
    l.default_order_direction   = DESCENDING

    l.column :category
    l.column :content
    l.column :source_name, header: "Name"
    l.column :quote
    l.column :status

    l.column :created_at,
      :sortable => true,
      :default_order_direction => DESCENDING

    l.filter :status,
      :collection => -> { Quote.status_select_collection }
  end
end

