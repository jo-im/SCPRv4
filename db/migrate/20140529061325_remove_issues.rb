class RemoveIssues < ActiveRecord::Migration
  def change
    drop_table :issues
    drop_table :article_issues
    drop_table :category_issues
  end
end
