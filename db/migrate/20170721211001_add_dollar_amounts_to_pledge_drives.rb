class AddDollarAmountsToPledgeDrives < ActiveRecord::Migration
  def change
    add_column :pledge_drives, :current_dollars, :integer
    add_column :pledge_drives, :goal_dollars, :integer
  end
end
