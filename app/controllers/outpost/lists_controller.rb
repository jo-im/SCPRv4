class Outpost::ListsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 3

    l.column :title

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :status

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING
  end

  def update
    @record.assign_attributes(list_params)
    if @record.save
      notice "Saved #{@record.simple_title}"
      respond_with :outpost, @record, location: requested_location
    else
      breadcrumb "Edit", nil, @record.to_title
      render :edit
    end
  end

  private

  def list_params
    params.require(:list).permit(:title, :context, :status, :starts_at, :ends_at, :position, :items_json, :content_type)
  end
end

