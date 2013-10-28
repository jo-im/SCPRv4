class Outpost::ContentShellsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :site
    l.column :byline
    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :site, collection: -> { ContentShell.sites_select_collection }
    l.filter :status, collection: -> { ContentBase.status_text_collect }
  end
end
