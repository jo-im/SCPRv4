class RemoveSlugLimits < ActiveRecord::Migration
  def up
    change_column "blogs_blog", "slug", :string
    change_column "blogs_entry", "slug", :string
    change_column "contentbase_category", "slug", :string
    change_column "events", "slug", :string
    change_column "news_story", "slug", :string
    change_column "pij_query", "slug", :string
    change_column "shows_segment", "slug", :string
  end

  def down
    change_column "blogs_blog", "slug", :string, limit: 50
    change_column "blogs_entry", "slug", :string, limit: 50
    change_column "contentbase_category", "slug", :string, limit: 50
    change_column "events", "slug", :string, limit: 50
    change_column "news_story", "slug", :string, limit: 50
    change_column "pij_query", "slug", :string, limit: 50
    change_column "shows_segment", "slug", :string, limit: 50
  end
end
