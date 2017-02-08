class Outpost::LandingPagesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 3

    l.column :title

    l.column :created_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end


  private

  # FIXME Need a better way to ignore the search action in
  # a controller.
  def search
  end
end
