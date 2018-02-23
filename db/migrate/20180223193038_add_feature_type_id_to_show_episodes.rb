class AddFeatureTypeIdToShowEpisodes < ActiveRecord::Migration
  def change
    add_column :shows_episode, :feature_type_id, :integer
  end
end
