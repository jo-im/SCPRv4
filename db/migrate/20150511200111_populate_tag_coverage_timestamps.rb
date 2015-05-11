class PopulateTagCoverageTimestamps < ActiveRecord::Migration
  def up
    Tag.reset_column_information
    Tag.all.each do |tag|
      articles = tag.articles
      tag.update began_at: articles.last.try(:public_datetime), most_recent_at: articles.first.try(:public_datetime)  
    end
  end
  def down
    Tag.reset_column_information
    Tag.update_all began_at: nil, most_recent_at: nil
  end
end
