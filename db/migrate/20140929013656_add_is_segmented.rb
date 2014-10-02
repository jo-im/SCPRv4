class AddIsSegmented < ActiveRecord::Migration
  def change
    rename_column :programs_kpccprogram, :is_episodic, :is_segmented
  end
end
