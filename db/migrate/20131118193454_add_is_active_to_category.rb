class AddIsActiveToCategory < ActiveRecord::Migration
  def change
    add_column :contentbase_category, :is_active, :boolean
  end
end
