class Outpost::EditionsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING

    l.column :title

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status
    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :status, collection: -> { Edition.status_select_collection }
  end

  private

  def search
    # TODO - not this.
    #
    # This is a hack so the search form doesn't show up.
    # Outpost checks the controllers action methods for #search.
    # ResourceController defines that method (via Searchable module).
    # So by overriding #search as a private method, it won't be
    # considered an action method and therefore won't be in the
    # action_methods array.
  end
end
