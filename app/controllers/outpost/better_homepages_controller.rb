class Outpost::BetterHomepagesController < Outpost::ResourceController
  outpost_controller

  prepend_view_path 'app/views/better_homepage'

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 3

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end

  #--------------------

  def preview
    @homepage = Outpost.obj_by_key(params[:obj_key]) || BetterHomepage.new

    with_rollback @homepage do
      @homepage.id = params[:id]
      @homepage.assign_attributes(params[:better_homepage] || {})
      @current_program  = ScheduleOccurrence.current.first
      @content = @homepage.content
      @title = @homepage.to_title
      render "better_homepage/index", layout: 'layouts/better_homepage'
    end
  end
end
