class ChangeFeatureTypeInArticles < ActiveRecord::Migration
  def change
    remove_column :news_story, :feature_type
    remove_column :blogs_entry, :feature_type
    remove_column :shows_segment, :feature_type
    add_column :news_story, :feature_type, :integer
    add_index :news_story, :feature_type
    add_column :blogs_entry, :feature_type, :integer
    add_index :blogs_entry, :feature_type
    add_column :shows_segment, :feature_type, :integer
    add_index :shows_segment, :feature_type
  end
end
