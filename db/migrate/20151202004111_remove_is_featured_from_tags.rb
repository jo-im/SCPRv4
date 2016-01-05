class RemoveIsFeaturedFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :is_featured
  end
  def down
    add_column :tags, :is_featured, :boolean, default: false, index: true
  end
end
