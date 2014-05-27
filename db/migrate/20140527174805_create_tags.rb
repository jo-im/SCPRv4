class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title
      t.string :slug # uuid for API
      t.timestamps

      t.index :slug
      t.index :created_at
    end

    create_table :taggings do |t|
      t.integer :taggable_type
      t.integer :taggable_id
      t.integer :tag_id

      t.timestamps

      t.index [:taggable_type, :taggable_id]
      t.index :tag_id
    end
  end
end
