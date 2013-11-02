class AddFeatureTypeToNewsStory < ActiveRecord::Migration
  def change
    add_column :news_story, :feature_type, :string
    add_index :news_story, :feature_type
  end
end
