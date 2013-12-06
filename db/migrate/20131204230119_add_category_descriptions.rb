class AddCategoryDescriptions < ActiveRecord::Migration
  def change
    add_column :contentbase_category, :description, :string
  end
end
