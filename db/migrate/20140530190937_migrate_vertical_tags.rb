class MigrateVerticalTags < ActiveRecord::Migration
  def up
    Vertical.all.each do |vertical|
      vertical.issues.each do |issue|
        tag = Tag.find_by_slug(issue.slug)
        vertical.tags << tag
      end

      vertical.save!
    end
  end

  def down; end
end
