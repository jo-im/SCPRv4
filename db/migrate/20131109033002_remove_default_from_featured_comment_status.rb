class RemoveDefaultFromFeaturedCommentStatus < ActiveRecord::Migration
  def up
    change_column_default :contentbase_featuredcomment, :status, nil
  end

  def down
    change_column_default :contentbase_featuredcomment, :status, 0
  end
end
