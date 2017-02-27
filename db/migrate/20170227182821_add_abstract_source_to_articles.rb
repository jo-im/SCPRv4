class AddAbstractSourceToArticles < ActiveRecord::Migration
  def up
    [:contentbase_contentshell, :news_story, :blogs_entry, :shows_segment].each do |table|
      add_column table, :abstract_source, :string
    end
  end
  def down
    [:contentbase_contentshell, :news_story, :blogs_entry, :shows_segment].each do |table|
      remove_column table, :abstract_source
    end
  end
end
