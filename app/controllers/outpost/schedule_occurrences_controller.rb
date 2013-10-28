class Outpost::ScheduleOccurrencesController < Outpost::ResourceController
  outpost_controller

  define_list do |l|
    l.default_order_attribute   = "updated_at"
    l.default_order_direction   = DESCENDING
    l.per_page                  = 50

    l.column :title
    l.column :starts_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.column :ends_at
    l.column :info_url, display: :display_link
    l.column :is_recurring?,
      :header     => "Recurring?",
      :display    => :display_boolean

    l.column :updated_at,
      :sortable                   => true,
      :default_order_direction    => DESCENDING

    l.filter :date,
      collection: -> { ScheduleOccurrence.date_select_collection }
  end
end
