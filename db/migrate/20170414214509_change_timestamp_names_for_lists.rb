class ChangeTimestampNamesForLists < ActiveRecord::Migration
  def change
    rename_column :lists, :start_time, :starts_at
    rename_column :lists, :end_time, :ends_at
  end
end