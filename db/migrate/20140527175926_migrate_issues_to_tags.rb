class MigrateIssuesToTags < ActiveRecord::Migration
  def change
    Issue.all.each do |issue|
      tag = Tag.create(title: issue.title, slug: issue.slug)
      issue.tags << tag
      issue.save!

      issue.articles.each do |article|
        article.original_object.tags << tag
        article.original_object.save!
      end
    end
  end
end
