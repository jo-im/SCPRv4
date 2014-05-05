class RemoveBlogauthorPosition < ActiveRecord::Migration
  def up
    remove_column :blogs_blogauthor, :position
  end

  def down
    add_column :blogs_blogauthor, :position, :integer
  end
end
