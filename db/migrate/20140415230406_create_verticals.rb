class CreateVerticals < ActiveRecord::Migration
  def change
    create_table :verticals do |t|
      t.string :slug
      t.integer :category_id
      t.string :title
      t.text :description
      t.integer :featured_interactive_style_id
      t.integer :blog_id
      t.integer :quote_id
      t.timestamps

      t.index :slug
      t.index :category_id
      t.index :blog_id
      t.index :quote_id
    end
  end
end
