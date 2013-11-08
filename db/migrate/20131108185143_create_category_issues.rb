class CreateCategoryIssues < ActiveRecord::Migration
  def change
    create_table :category_issues do |t|
      t.references :category
      t.references :issue

      t.timestamps
    end
    add_index :category_issues, :category_id
    add_index :category_issues, :issue_id
  end
end
