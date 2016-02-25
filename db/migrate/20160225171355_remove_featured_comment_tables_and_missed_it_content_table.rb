class RemoveFeaturedCommentTablesAndMissedItContentTable < ActiveRecord::Migration
  def up
    drop_table "contentbase_featuredcomment"
    drop_table "contentbase_featuredcommentbucket"
    drop_table "contentbase_misseditcontent"
  end
  def down
    create_table "contentbase_featuredcomment", force: :cascade do |t|
      t.integer  "bucket_id",    limit: 4,          null: false
      t.integer  "content_id",   limit: 4
      t.integer  "status",       limit: 4,          null: false
      t.string   "username",     limit: 255,        null: false
      t.text     "excerpt",      limit: 4294967295, null: false
      t.string   "content_type", limit: 255
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
    end

    add_index "contentbase_featuredcomment", ["bucket_id"], name: "contentbase_featuredcomment_25ef9024", using: :btree
    add_index "contentbase_featuredcomment", ["content_type", "content_id"], name: "index_contentbase_featuredcomment_on_content_type_and_content_id", using: :btree
    add_index "contentbase_featuredcomment", ["created_at"], name: "index_contentbase_featuredcomment_on_created_at", using: :btree
    add_index "contentbase_featuredcomment", ["status"], name: "index_contentbase_featuredcomment_on_status", using: :btree

    create_table "contentbase_featuredcommentbucket", force: :cascade do |t|
      t.string   "title",      limit: 255, null: false
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    add_index "contentbase_featuredcommentbucket", ["created_at"], name: "index_contentbase_featuredcommentbucket_on_created_at", using: :btree
    add_index "contentbase_featuredcommentbucket", ["title"], name: "index_contentbase_featuredcommentbucket_on_title", using: :btree
    add_index "contentbase_featuredcommentbucket", ["updated_at"], name: "index_contentbase_featuredcommentbucket_on_updated_at", using: :btree

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
  end
end
