class AddCoverageTimestampsToTags < ActiveRecord::Migration
  def up
  	add_column :tags, :began_at, :datetime
  	add_column :tags, :most_recent_at, :datetime
  end
  def down
  	remove_column :tags, :began_at
  	remove_column :tags, :most_recent_at
  end
end
