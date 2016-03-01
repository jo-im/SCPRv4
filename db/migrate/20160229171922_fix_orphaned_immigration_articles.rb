class FixOrphanedImmigrationArticles < ActiveRecord::Migration
  def up
    tag = Tag.where(slug: "immigration").first!
    # Models supported by API controller for Articles
    ["NewsStory","ShowSegment","BlogEntry","ContentShell"].
    each do |c|
      contents = c.constantize.where(category_id: 16)
      if contents.last.respond_to?(:tags)
        contents.each do |content|
          if !content.tags.include?(tag)
            content.tags << tag
          end
          content.update category_id: nil
        end
      end
    end
  end

  def down
    # Not completely undo-able.
  end
end
