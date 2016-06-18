class AddAbstractFieldToArticleTables < ActiveRecord::Migration
  TABLES = [:blogs_entry, :contentbase_contentshell, :events, :news_story, :pij_query, :shows_episode, :shows_segment]
  def up
    TABLES.each do |t|
      add_column t, :abstract, :text
    end
  end
  def down
    TABLES.each do |t|
      remove_column t, :abstract
    end
  end
end
