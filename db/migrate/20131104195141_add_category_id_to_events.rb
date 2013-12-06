class AddCategoryIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :category_id, :integer
    add_index :events, :category_id
  end
end
