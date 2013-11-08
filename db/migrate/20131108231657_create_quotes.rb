class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :quote
      t.string :source_name
      t.string :source_context
      t.references :category
      t.references :article, polymorphic: true

      t.timestamps
    end
    add_index :quotes, :category_id
    add_index :quotes, [:article_id, :article_type]
  end
end
