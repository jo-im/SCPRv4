class MakeLandingPageEventsPolymorphic < ActiveRecord::Migration
  def change
    if !table_exists?(:landing_page_contents)
      rename_table :landing_page_events, :landing_page_contents
      if !column_exists?(:landing_page_contents, :content_id) && !column_exists?(:landing_page_contents, :content_type)
        rename_column :landing_page_contents, :event_id, :content_id
        rename_column :landing_page_contents, :event_type, :content_type
      end
    end
  end
end
