class CreateCategoryArticles < ActiveRecord::Migration
  def change
    create_table :category_articles do |t|
      t.integer :position
      t.references :category
      t.references :article, polymorphic: true

      t.timestamps
    end
    add_index :category_articles, :position
    add_index :category_articles, :category_id
    add_index :category_articles, [:article_id, :article_type]
  end
end
