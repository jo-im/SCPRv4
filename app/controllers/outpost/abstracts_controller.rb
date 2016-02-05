class Outpost::AbstractsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :source
    l.column :url, display: :display_link
    l.column :article_published_at,
      :header                     => "Published At",
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :published_to_pmp?, display: :display_pmp_status

    l.filter :source, collection: -> { Abstract.sources_select_collection }
  end
end
