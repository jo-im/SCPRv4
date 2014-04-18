class RemoveOldColumns < ActiveRecord::Migration
  def change
    remove_column :contentbase_category, :is_active
    remove_column :contentbase_category, :featured_interactive_style_id
    remove_column :contentbase_category, :blog_id

    remove_column :category_issues, :category_id
    remove_column :category_reporters, :category_id
    remove_column :category_articles, :category_id

    remove_column :quotes, :category_id
    remove_column :quotes, :status
  end
end
