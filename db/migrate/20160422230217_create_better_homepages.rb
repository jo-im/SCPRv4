class CreateBetterHomepages < ActiveRecord::Migration
  def change
    create_table :better_homepages do |t|
      t.datetime   :published_at
      t.integer    :status,       limit: 4,   null: false
      t.datetime   :created_at,               null: false
      t.datetime   :updated_at,               null: false
      t.timestamps null: false
    end
  end
end
