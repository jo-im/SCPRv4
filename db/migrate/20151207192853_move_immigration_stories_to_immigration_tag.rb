class MoveImmigrationStoriesToImmigrationTag < ActiveRecord::Migration
  def up
    category = Category.where(slug: 'immigration').first!
    story_ids = NewsStory.where(category_id: category.id).pluck(:id)
    shell_ids = ContentShell.where(category_id: category.id).pluck(:id)
    tag_id    = Tag.where(slug: "immigration-3-0")
    story_ids.each do |story_id|
      Tagging.create taggable_id: story_id, taggable_type: "NewsStory", tag_id: tag_id
    end
    shell_ids.each do |shell_id|
      Tagging.create taggable_id: shell_id, taggable_type: "ContentShell", tag_id: tag_id
    end
    category.destroy
  end
  def down
    Category.create title: "Immigration & Emerging Communities", slug: "immigration"
    tag_id = Tag.where(slug: "immigration-3-0")
    Tagging.where(tag_id: tag_id, taggable_type: ["NewsStory", "ContentShell"]).destroy_all
  end
end
