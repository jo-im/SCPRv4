class CreateProgramArticles < ActiveRecord::Migration
  def change
    create_table :program_articles do |t|
      t.integer :position
      t.integer :article_id
      t.string :article_type
      t.integer :program_id
    end

    add_index :program_articles, [:article_id, :article_type]
    add_index :program_articles, [:position]
    add_index :program_articles, [:program_id]
  end
end
