class CreatePledgeDrives < ActiveRecord::Migration
  def change
    create_table :pledge_drives do |t|
      t.datetime :starts_at, index: true, null: false
      t.datetime :ends_at, index: true, null: false
      t.boolean :enabled, default: false
      t.timestamps null: false
    end
  end
end
