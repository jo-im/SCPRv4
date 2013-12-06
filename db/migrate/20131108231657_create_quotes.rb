class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.text :quote
      t.string :source_name
      t.string :source_context
      t.references :category
      t.references :content, polymorphic: true

      t.integer :status
      t.timestamps
    end
    add_index :quotes, :category_id
    add_index :quotes, [:content_id, :content_type]
    add_index :quotes, :created_at
    add_index :quotes, :status
  end
end
