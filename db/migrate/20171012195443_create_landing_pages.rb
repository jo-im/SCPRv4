class CreateLandingPages < ActiveRecord::Migration
  def change
    if !table_exists?(:landing_pages)
      create_table :landing_pages do |t|
        t.string   :title,                         limit: 255
        t.text     :description,                   limit: 65535
        t.datetime :created_at
        t.datetime :updated_at
      end
    end
  end
end