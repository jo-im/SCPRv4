class AddIsFeaturedToExternalPrograms < ActiveRecord::Migration
  def change
    if !column_exists?(:external_programs, :is_featured)
      add_column :external_programs, :is_featured, :boolean
    end
  end
end
