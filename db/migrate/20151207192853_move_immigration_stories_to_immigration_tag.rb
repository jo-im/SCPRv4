class MoveImmigrationStoriesToImmigrationTag < ActiveRecord::Migration
  CONTENT_TYPES = ["NewsStory", "ContentShell", "BlogEntry", "ShowSegment", "Event", "Podcast", "Abstract", "Vertical"]
  def up
    category = Category.where(slug: 'immigration').first!
    tag_id   = Tag.where(slug: "immigration").first!.id
    CONTENT_TYPES.each do |content_type|
      content_type.constantize.where(category_id: category.id).find_in_batches do |batch|
        batch.map(&:id).each do |content_id|
          Tagging.create taggable_id: content_id, taggable_type: content_type, tag_id: tag_id
        end
      end
    end
    category.destroy
  end
  def down
    category = Category.create title: "Immigration & Emerging Communities", slug: "immigration"
    tag_id   = Tag.where(slug: "immigration").first!.id
    CONTENT_TYPES.each do |content_type|
      table_name = content_type.constantize.table_name.to_sym
      unless column_exists?(table_name, :category_id)
        add_column table_name, :category_id, :integer, index: true
      end
    end
    Tagging.where(tag_id: tag_id, taggable_type: CONTENT_TYPES).each do |tagging|
      if taggable = tagging.taggable
        taggable.update category_id: category.id
      end
      tagging.destroy
    end
  end
end
