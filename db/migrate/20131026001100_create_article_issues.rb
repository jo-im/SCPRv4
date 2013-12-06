class CreateArticleIssues < ActiveRecord::Migration
  def change
    create_table :article_issues do |t|
      t.references :issue
      t.references :article, polymorphic: true

      t.timestamps
    end
    add_index :article_issues, :issue_id
    add_index :article_issues, [:article_id, :article_type]
  end
end
