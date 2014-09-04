class RenameDisplayEpisodesToIsEpisodic < ActiveRecord::Migration
  def change
    rename_column :programs_kpccprogram, :display_episodes, :is_episodic
  end
end
