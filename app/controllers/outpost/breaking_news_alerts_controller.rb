class Outpost::BreakingNewsAlertsController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "published_at"
    l.default_order_direction   = DESCENDING

    l.column :headline
    l.column :alert_type,
      :header     => "Type",
      :display    => ->(r) { BreakingNewsAlert::ALERT_TYPES[r.alert_type] }

    l.column :status
    l.column :visible, header: "Visible?"
    l.column :email_sent, header: "Emailed?"
    l.column :mobile_notification_sent, header: "Pushed?"

    l.column :published_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING


    l.filter :alert_type,
      :title        => "Type",
      :collection   => -> { BreakingNewsAlert.types_select_collection }

    l.filter :email_sent,
      :title        => "Email Sent?",
      :collection   => :boolean

    l.filter :mobile_notification_sent,
      :title        => "Mobile Notification Sent?",
      :collection   => :boolean
  end

  def bodies
    @record = BreakingNewsAlert.find(params[:id])
  end
end
