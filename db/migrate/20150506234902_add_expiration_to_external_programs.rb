class AddExpirationToExternalPrograms < ActiveRecord::Migration
  def change
  	add_column :external_programs, :days_to_expiry, :integer
  	add_index :external_programs, :days_to_expiry
  end
end
