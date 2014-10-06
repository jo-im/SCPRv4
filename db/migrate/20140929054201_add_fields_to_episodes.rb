class AddFieldsToEpisodes < ActiveRecord::Migration
  def change
    rename_column :shows_episode, :body, :teaser
    add_column :shows_episode, :body, :text
    add_column :shows_episode, :asset_display_id, :integer
    add_index :shows_episode, :asset_display_id
  end
end
