class PopulateTagCoverageTimestamps < ActiveRecord::Migration
  def up
    Tag.reset_column_information
    Tag.all.each do |tag|
      oldest_article_timestamp  = tag.articles(order:"public_datetime asc",limit:1).first.try(:public_datetime)
      newest_article_timestamp  = tag.articles(order:"public_datetime desc",limit:1).first.try(:public_datetime)
      tag.update began_at: oldest_article_timestamp, most_recent_at: newest_article_timestamp
    end
  end
  def down
    Tag.update_all began_at: nil, most_recent_at: nil
  end
end
