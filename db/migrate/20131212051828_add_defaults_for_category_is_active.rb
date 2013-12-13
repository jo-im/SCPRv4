class AddDefaultsForCategoryIsActive < ActiveRecord::Migration
  def up
    change_column :contentbase_category, :is_active, :boolean, null: false, default: false
    Category.where(is_active: nil).update_all(is_active: false)
  end

  def down
    change_column :contentbase_category, :is_active, :boolean, null: true, default: nil
  end
end
