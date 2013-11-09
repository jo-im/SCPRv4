class Outpost::QuotesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "created_at"
    l.default_order_direction   = DESCENDING

    l.column :category
    l.column :article
    l.column :source_name
    l.column :source_context
    l.column :quote
    l.column :status
    l.column :created_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :status,
      :collection => -> { ContentBase.status_text_collect }
  end
end

