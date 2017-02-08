class AddLandingPageReporters < ActiveRecord::Migration
  def change
    if !table_exists?(:landing_page_reporters)
      create_table :landing_page_reporters do |t|
        t.integer  :bio_id
        t.integer  :landing_page_id
        t.datetime :created_at
        t.datetime :updated_at
      end
    end
  end
end