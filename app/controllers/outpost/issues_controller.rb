class Outpost::IssuesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title, sortable: true
    l.column :slug, sortable: true
    l.column :description
    l.column :is_active

#    l.filter :is_news,
#      :title        => "News?",
#      :collection   => :boolean
  end
end

