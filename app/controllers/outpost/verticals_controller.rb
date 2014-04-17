class Outpost::VerticalsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "title"
    l.default_order_direction   = ASCENDING

    l.column :title
    l.column :slug
    l.column :category
  end


  private

  # FIXME Need a better way to ignore the search action in
  # a controller.
  def search
  end
end
