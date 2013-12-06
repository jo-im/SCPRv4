class RemoveAssetSchemes < ActiveRecord::Migration
  def change
    remove_column :blogs_entry, :blog_asset_scheme
    remove_column :news_story, :story_asset_scheme
    remove_column :news_story, :extra_asset_scheme
    remove_column :shows_segment, :segment_asset_scheme
    remove_column :events, :event_asset_scheme
  end
end
