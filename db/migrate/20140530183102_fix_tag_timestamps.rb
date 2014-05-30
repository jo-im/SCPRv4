class FixTagTimestamps < ActiveRecord::Migration
  def up
    Issue.all.each do |issue|
      tag = Tag.find_by_slug!(issue.slug)

      # 'articles' method is sorted in reverse chron
      if ts = issue.articles.last.try(:public_datetime)
        tag.update_column :created_at, ts
      end

      if ts = issue.articles.first.try(:public_datetime)
        tag.update_column :updated_at, ts
      end

      issue.articles.each do |article|
        if !article.original_object.tags.include?(tag)
          article.original_object.tags << tag
          article.original_object.save!
        end
      end
    end
  end

  def down
    # nope
  end
end
