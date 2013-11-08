class Outpost::HomepagesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 3

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status
    l.column :base, header: "Template"

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end

  #--------------------

  def preview
    @homepage = Outpost.obj_by_key(params[:obj_key]) || Homepage.new

    with_rollback @homepage do
      @homepage.assign_attributes(params[:homepage])

      if @homepage.unconditionally_valid?
        @title = @homepage.to_title

        render "/home/_#{@homepage.base}",
          :layout => "outpost/preview/application",
          :locals => { homepage: @homepage }

      else
        render_preview_validation_errors(@homepage)
      end
    end
  end
end
