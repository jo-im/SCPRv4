class FixOrphanedImmigrationArticles < ActiveRecord::Migration
  def up
    # Models supported by API controller for Articles
    ["NewsStory","ShowSegment","BlogEntry","ContentShell"].each do |c|
      c.constantize.where(category_id: 16).update_all(category_id: nil)
    end
  end

  def down
    # Not undo-able.
  end
end
