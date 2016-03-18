class AddNeedsReindexToArticleModels < ActiveRecord::Migration
  TABLES = [:abstracts, :blogs_entry, :contentbase_contentshell, :events, :news_story, :pij_query, :shows_episode, :shows_segment]
  def up
    TABLES.each do |t|
      add_column t, :needs_reindex, :boolean, default: false
    end
  end
  def down
    TABLES.each do |t|
      remove_column t, :needs_reindex
    end
  end
end
