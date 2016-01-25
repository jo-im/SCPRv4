class RemoveDeprecatedTimestampsFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :began_at
    remove_column :tags, :most_recent_at
  end
  def down
    add_column :tags, :most_recent_at, :datetime, unless: column_exists?(:tags, :most_recent_at)
    add_column :tags, :began_at, :datetime, unless: column_exists?(:tags, :began_at)
    Tag.all.each do |tag|
      taggables = tag.taggings
        .map{|t| t.taggable}
        .sort{|a, b| (a.try(:published_at) || a.try(:created_at)) <=> (b.try(:published_at) || b.try(:created_at))}
      tag.update began_at: taggables.first.try(:published_at), most_recent_at: taggables.last.try(:published_at)
    end
  end
end
