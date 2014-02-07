class AddBlogIdToCategory < ActiveRecord::Migration
  def change
    add_column :contentbase_category, :blog_id, :integer
    add_index :contentbase_category, :blog_id
  end
end
