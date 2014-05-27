class MigrateIssuesToTags < ActiveRecord::Migration
  def change
    Issue.all.each do |issue|
      tag = Tag.create(title: issue.title, slug: issue.slug)
      issue.tags << tag
      issue.save!
    end
  end
end
