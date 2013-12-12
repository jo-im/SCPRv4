class AddDefaultsForCategoryIsActive < ActiveRecord::Migration
  def up
    change_column :contentbase_category, :is_active, :boolean, null: false, default: false
  end

  def down
    change_column :contentbase_category, :is_active, :boolean, null: true, default: nil
  end
end
