class PopulateTagCoverageTimestamps < ActiveRecord::Migration
  def up
    Tag.all.each do |tag|
      articles = tag.articles.order("created_at DESC")
      tag.update began_at: tag.articles.last.created_at, most_recent_at: tag.articles.first.created_at      
    end
  end
  def down
    Tag.update_all began_at: nil, most_recent_at: nil
  end
end
