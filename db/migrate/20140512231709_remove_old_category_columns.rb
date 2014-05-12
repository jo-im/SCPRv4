class RemoveOldCategoryColumns < ActiveRecord::Migration
  def up
    remove_column :contentbase_category, :is_news
    remove_column :contentbase_category, :description
    remove_column :blogs_blog, :is_news
  end

  def down
    add_column :contentbase_category, :is_news, :boolean
    add_column :contentbase_category, :description, :string
    add_column :blogs_blog, :is_news, :boolean
  end
end
