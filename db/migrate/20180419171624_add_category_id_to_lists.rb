class AddCategoryIdToLists < ActiveRecord::Migration
  def up
    add_column :lists, :category_id, :integer, limit: 4
  end

  def down
    remove_column :lists, :category_id
  end
end
