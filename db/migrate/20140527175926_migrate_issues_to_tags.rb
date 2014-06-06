class MigrateIssuesToTags < ActiveRecord::Migration
  def up
    Issue.all.each do |issue|
      tag = Tag.create(
        :title          => issue.title,
        :slug           => issue.slug,
        :description    => issue.description,
        :is_featured    => issue.is_active
      )

      if ts = issue.articles.first.try(:public_datetime)
        tag.send :write_attribute, :created_at, ts
      end

      if ts = issue.articles.last.try(:public_datetime)
        tag.send :write_attribute, :updated_at, ts
      end

      issue.articles.each do |article|
        article.original_object.tags << tag
        article.original_object.save!
      end
    end
  end

  def down
    # nope
  end
end
