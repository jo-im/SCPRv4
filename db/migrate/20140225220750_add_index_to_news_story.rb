class AddIndexToNewsStory < ActiveRecord::Migration
  def change
    add_index :news_story, [:source, :published_at]
  end
end
