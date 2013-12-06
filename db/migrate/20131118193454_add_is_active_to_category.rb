class AddIsActiveToCategory < ActiveRecord::Migration
  def change
    add_column :contentbase_category, :is_active, :boolean
    add_index :contentbase_category, :is_active
  end
end
