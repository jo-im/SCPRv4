class RemoveMissedItBuckets < ActiveRecord::Migration
  def up
    remove_column "blogs_blog", :missed_it_bucket_id
    remove_column "layout_homepage", :missed_it_bucket_id
    drop_table "contentbase_misseditbucket"
  end
  def down
    create_table "contentbase_misseditbucket", force: :cascade do |t|
      t.string   "title",      limit: 255, null: false
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
      t.string   "slug",       limit: 255
    end

    add_index "contentbase_misseditbucket", ["title"], name: "index_contentbase_misseditbucket_on_title", using: :btree

    create_table "contentbase_misseditcontent", force: :cascade do |t|
      t.integer  "bucket_id",    limit: 4,                null: false
      t.integer  "content_id",   limit: 4
      t.integer  "position",     limit: 4,   default: 99, null: false
      t.string   "content_type", limit: 255
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
    end

    add_index "contentbase_misseditcontent", ["bucket_id"], name: "contentbase_misseditcontent_25ef9024", using: :btree
    add_index "contentbase_misseditcontent", ["content_type", "content_id"], name: "index_contentbase_misseditcontent_on_content_type_and_content_id", using: :btree

    add_column "layout_homepage", "missed_it_bucket_id", :integer, limit: 4
    add_index "layout_homepage", ["missed_it_bucket_id"], name: "layout_homepage_d12628ce", using: :btree

    add_column "blogs_blog", "missed_it_bucket_id", :integer, limit: 4
    add_index "blogs_blog", ["missed_it_bucket_id"], name: "blogs_blog_d12628ce", using: :btree

  end
end
