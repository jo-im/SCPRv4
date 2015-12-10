class RemoveImmigrationCommentBucket < ActiveRecord::Migration
  def up
    FeaturedCommentBucket.where(title: "Category: Immigration & Emerging Communities").each do |bucket|
      bucket.comments.destroy_all
      bucket.destroy
    end
  end
  def down
    # ¯\_(ツ)_/¯
  end
end
