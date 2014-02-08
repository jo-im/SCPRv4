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
    l.column :email_sent, header: "Emailed?"

    l.column :updated_at,
      :header                     => "Last Updated",
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :status, collection: -> { Edition.status_select_collection }

    l.filter :email_sent,
      :title        => "Email Sent?",
      :collection   => :boolean
  end
end
