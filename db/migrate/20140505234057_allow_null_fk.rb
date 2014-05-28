class AllowNullFk < ActiveRecord::Migration
  def up
    change_column :blogs_blogauthor, :blog_id, :integer, null: true
    change_column :blogs_blogauthor, :author_id, :integer, null: true
  end

  def down
    change_column :blogs_blogauthor, :blog_id, :integer, null: false
    change_column :blogs_blogauthor, :author_id, :integer, null: false
  end
end
