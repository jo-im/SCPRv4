class RemoveDisplaySegmentsFromPrograms < ActiveRecord::Migration
  def change
    remove_column :programs_kpccprogram, :display_segments, :boolean
  end
end
