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
    home = Outpost.obj_by_key(params[:obj_key]) || BetterHomepage.new

    with_rollback home do
      home.id = params[:id]
      home.assign_attributes(params[:better_homepage] || {})
      @homepage = home.to_indexable
      @content  = @homepage.content.map do |c| 
        c.article = ContentBase.safe_obj_by_key(c.obj_key).try(:to_article) || Article.new
        c
      end
      @current_program  = ScheduleOccurrence.current.first

      @title = @homepage.to_title
      render "better_homepage/index",
        :layout => 'layouts/better_homepage', # "outpost/preview/application",
        :locals => { homepage: @homepage }
    end
  end
end
