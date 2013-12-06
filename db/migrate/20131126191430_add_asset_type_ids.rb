class AddAssetTypeIds < ActiveRecord::Migration
  def change
    [:blogs_entry, :events, :news_story, :shows_segment].each do |t|
      add_column t, :asset_display_id, :integer
      add_index t, :asset_display_id
    end
  end
end
