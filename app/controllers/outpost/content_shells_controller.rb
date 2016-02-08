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

    l.column :status, display: :display_article_status
    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :site, collection: -> { ContentShell.sites_select_collection }
    l.filter :status, collection: -> { ContentShell.status_select_collection }
  end
end
