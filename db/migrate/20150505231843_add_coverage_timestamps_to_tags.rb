class AddCoverageTimestampsToTags < ActiveRecord::Migration
  def up
  	add_column :tags, :began_at, :datetime, index: true, default: Time.now
  	add_column :tags, :most_recent_at, :datetime, index: true, default: Time.now
  	Tag.all.each do |tag|
			tag.update began_at: tag.articles.last.created_at, most_recent_at: tag.articles.first.created_at  		
  	end
  end
  def down
  	remove_column :tags, :began_at
  	remove_column :tags, :most_recent_at
  end
end
