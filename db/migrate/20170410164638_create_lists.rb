class CreateLists < ActiveRecord::Migration
  def up
    create_table :lists do |t|
      t.string :title
      t.string :context
      t.integer :position, default: 0
      t.integer :status, index: true
      t.datetime :start_time, index: true
      t.datetime :end_time, index: true
      t.datetime :published_at, index: true
      t.timestamps null: false
    end
    Permission.create resource: "List"
  end

  def down
    drop_table :lists
    Permission.where(resource: "List").destroy_all
  end
end
