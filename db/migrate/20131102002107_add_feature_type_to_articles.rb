class AddFeatureTypeToArticles < ActiveRecord::Migration
  def change
    add_column :news_story, :feature_type_id, :integer
    add_index :news_story, :feature_type_id

    add_column :blogs_entry, :feature_type_id, :integer
    add_index :blogs_entry, :feature_type_id

    add_column :shows_segment, :feature_type_id, :integer
    add_index :shows_segment, :feature_type_id

    add_column :contentbase_contentshell, :feature_type_id, :integer
    add_index :contentbase_contentshell, :feature_type_id
  end
end
