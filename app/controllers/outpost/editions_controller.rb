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
    l.column :shortlist_email_sent, header: "Email Sent?"
    l.column :monday_shortlist_email_sent, header: "Monday Email Sent?"

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :status, collection: -> { Edition.status_select_collection }

    l.filter :shortlist_email_sent,
      :title        => "Email Sent?",
      :collection   => :boolean

    l.filter :monday_shortlist_email_sent,
      :title        => "Monday Email Sent?",
      :collection   => :boolean
  end

  def bodies
    @record = Edition.find(params[:id])
  end

end
