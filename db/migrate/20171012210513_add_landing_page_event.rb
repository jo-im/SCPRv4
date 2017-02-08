class AddLandingPageEvent < ActiveRecord::Migration
  def change
    if !table_exists?(:landing_page_events)
      create_table :landing_page_events do |t|
        t.integer  :position
        t.integer  :event_id
        t.string   :event_type
        t.integer  :landing_page_id
        t.datetime :created_at
        t.datetime :updated_at
      end
    end
  end
end