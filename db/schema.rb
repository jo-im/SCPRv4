# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180419171624) do

  create_table "abstracts", force: :cascade do |t|
    t.string   "source",               limit: 255
    t.string   "url",                  limit: 255
    t.string   "headline",             limit: 255
    t.text     "summary",              limit: 16777215
    t.integer  "category_id",          limit: 4
    t.datetime "article_published_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "needs_reindex",                         default: false
  end

  add_index "abstracts", ["article_published_at"], name: "index_abstracts_on_article_published_at", using: :btree
  add_index "abstracts", ["category_id"], name: "index_abstracts_on_category_id", using: :btree
  add_index "abstracts", ["source"], name: "index_abstracts_on_source", using: :btree
  add_index "abstracts", ["updated_at"], name: "index_abstracts_on_updated_at", using: :btree

  create_table "apple_news_articles", force: :cascade do |t|
    t.integer  "record_id",   limit: 4
    t.string   "record_type", limit: 255
    t.string   "uuid",        limit: 255
    t.string   "revision",    limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "apple_news_articles", ["record_id"], name: "index_apple_news_articles_on_record_id", using: :btree
  add_index "apple_news_articles", ["record_type"], name: "index_apple_news_articles_on_record_type", using: :btree

  create_table "assethost_contentasset", force: :cascade do |t|
    t.integer "content_id",   limit: 4
    t.integer "position",     limit: 4,          default: 99
    t.integer "asset_id",     limit: 4
    t.text    "caption",      limit: 4294967295,                 null: false
    t.string  "content_type", limit: 255
    t.boolean "inline",                          default: false
  end

  add_index "assethost_contentasset", ["content_id", "content_type"], name: "index_assethost_contentasset_on_content_id_and_content_type", using: :btree
  add_index "assethost_contentasset", ["position"], name: "index_assethost_contentasset_on_asset_order", using: :btree

  create_table "auth_user", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.string   "old_password",    limit: 255
    t.boolean  "can_login",                   null: false
    t.boolean  "is_superuser",                null: false
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest", limit: 255
    t.string   "name",            limit: 255
  end

  add_index "auth_user", ["can_login"], name: "index_auth_user_on_can_login", using: :btree
  add_index "auth_user", ["is_superuser"], name: "index_auth_user_on_is_superuser", using: :btree
  add_index "auth_user", ["name"], name: "index_auth_user_on_name", using: :btree
  add_index "auth_user", ["username", "can_login"], name: "index_auth_user_on_username_and_can_login", using: :btree

  create_table "better_homepages", force: :cascade do |t|
    t.datetime "published_at"
    t.integer  "status",       limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bios_bio", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "slug",           limit: 255
    t.text     "bio",            limit: 16777215
    t.string   "title",          limit: 255
    t.boolean  "is_public",                       default: false, null: false
    t.string   "twitter_handle", limit: 255
    t.integer  "asset_id",       limit: 4
    t.string   "short_bio",      limit: 255
    t.string   "phone_number",   limit: 255
    t.string   "name",           limit: 255
    t.string   "email",          limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "last_name",      limit: 255
  end

  add_index "bios_bio", ["is_public"], name: "index_bios_bio_on_is_public", using: :btree
  add_index "bios_bio", ["last_name", "is_public"], name: "index_bios_bio_on_last_name_and_is_public", using: :btree
  add_index "bios_bio", ["last_name"], name: "index_bios_bio_on_last_name", using: :btree
  add_index "bios_bio", ["name"], name: "index_bios_bio_on_name", using: :btree
  add_index "bios_bio", ["slug"], name: "index_bios_bio_on_slug", using: :btree

  create_table "blogs_blog", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "slug",                limit: 255
    t.text     "description",         limit: 4294967295
    t.boolean  "is_active",                              default: false, null: false
    t.string   "teaser",              limit: 255
    t.integer  "missed_it_bucket_id", limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "twitter_handle",      limit: 255
  end

  add_index "blogs_blog", ["is_active"], name: "index_blogs_blog_on_is_active", using: :btree
  add_index "blogs_blog", ["missed_it_bucket_id"], name: "blogs_blog_d12628ce", using: :btree
  add_index "blogs_blog", ["name"], name: "index_blogs_blog_on_name", using: :btree
  add_index "blogs_blog", ["slug"], name: "slug", unique: true, using: :btree

  create_table "blogs_blogauthor", force: :cascade do |t|
    t.integer  "blog_id",    limit: 4
    t.integer  "author_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "blogs_blogauthor", ["author_id", "blog_id"], name: "index_blogs_blogauthor_on_author_id_and_blog_id", using: :btree
  add_index "blogs_blogauthor", ["author_id"], name: "blogs_blog_authors_64afdb51", using: :btree
  add_index "blogs_blogauthor", ["blog_id"], name: "blogs_blog_authors_472bc96c", using: :btree

  create_table "blogs_entry", force: :cascade do |t|
    t.string   "headline",         limit: 255
    t.string   "slug",             limit: 255
    t.text     "body",             limit: 4294967295
    t.integer  "blog_id",          limit: 4
    t.datetime "published_at"
    t.integer  "status",           limit: 4,                          null: false
    t.string   "short_headline",   limit: 255
    t.text     "teaser",           limit: 4294967295
    t.integer  "wp_id",            limit: 4
    t.integer  "dsq_thread_id",    limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "category_id",      limit: 4
    t.boolean  "is_from_pij",                         default: false, null: false
    t.integer  "feature_type_id",  limit: 4
    t.integer  "asset_display_id", limit: 4
    t.boolean  "needs_reindex",                       default: false
    t.text     "abstract",         limit: 65535
    t.string   "abstract_source",  limit: 255
  end

  add_index "blogs_entry", ["asset_display_id"], name: "index_blogs_entry_on_asset_display_id", using: :btree
  add_index "blogs_entry", ["blog_id"], name: "blogs_entry_blog_id", using: :btree
  add_index "blogs_entry", ["category_id"], name: "blogs_entry_42dc49bc", using: :btree
  add_index "blogs_entry", ["feature_type_id"], name: "index_blogs_entry_on_feature_type_id", using: :btree
  add_index "blogs_entry", ["published_at"], name: "index_blogs_entry_on_published_at", using: :btree
  add_index "blogs_entry", ["status", "published_at"], name: "index_blogs_entry_on_status_and_published_at", using: :btree
  add_index "blogs_entry", ["status"], name: "index_blogs_entry_on_status", using: :btree
  add_index "blogs_entry", ["updated_at"], name: "index_blogs_entry_on_updated_at", using: :btree

  create_table "broadcast_contents", force: :cascade do |t|
    t.string   "headline",     limit: 255
    t.text     "body",         limit: 65535
    t.integer  "content_id",   limit: 4
    t.string   "content_type", limit: 255
    t.integer  "status",       limit: 4,     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "broadcast_contents", ["content_type", "content_id"], name: "index_broadcast_contents_on_content_type_and_content_id", using: :btree

  create_table "caches", force: :cascade do |t|
    t.string "key",   limit: 255
    t.binary "value", limit: 16777215
  end

  add_index "caches", ["key"], name: "index_caches_on_key", using: :btree

  create_table "category_articles", force: :cascade do |t|
    t.integer  "position",     limit: 4
    t.integer  "article_id",   limit: 4
    t.string   "article_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "vertical_id",  limit: 4
  end

  add_index "category_articles", ["article_id", "article_type"], name: "index_category_articles_on_article_id_and_article_type", using: :btree
  add_index "category_articles", ["position"], name: "index_category_articles_on_position", using: :btree
  add_index "category_articles", ["vertical_id"], name: "index_category_articles_on_vertical_id", using: :btree

  create_table "category_reporters", force: :cascade do |t|
    t.integer  "bio_id",      limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "vertical_id", limit: 4
  end

  add_index "category_reporters", ["bio_id"], name: "index_category_reporters_on_bio_id", using: :btree
  add_index "category_reporters", ["vertical_id"], name: "index_category_reporters_on_vertical_id", using: :btree

  create_table "contentbase_category", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "slug",              limit: 255
    t.integer  "comment_bucket_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "contentbase_category", ["comment_bucket_id"], name: "contentbase_category_36c0cbca", using: :btree
  add_index "contentbase_category", ["slug"], name: "contentbase_category_a951d5d6", using: :btree
  add_index "contentbase_category", ["title"], name: "index_contentbase_category_on_title", using: :btree

  create_table "contentbase_contentalarm", force: :cascade do |t|
    t.integer  "content_id",   limit: 4
    t.datetime "fire_at"
    t.string   "content_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "contentbase_contentalarm", ["content_id", "content_type"], name: "index_contentbase_contentalarm_on_content_id_and_content_type", using: :btree
  add_index "contentbase_contentalarm", ["fire_at"], name: "index_contentbase_contentalarm_on_fire_at", using: :btree

  create_table "contentbase_contentbyline", force: :cascade do |t|
    t.integer  "content_id",   limit: 4
    t.integer  "user_id",      limit: 4
    t.string   "name",         limit: 255,             null: false
    t.integer  "role",         limit: 4,   default: 0, null: false
    t.string   "content_type", limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "contentbase_contentbyline", ["content_id", "content_type"], name: "index_contentbase_contentbyline_on_content_id_and_content_type", using: :btree
  add_index "contentbase_contentbyline", ["user_id"], name: "contentbase_contentbyline_fbfc09f1", using: :btree

  create_table "contentbase_contentshell", force: :cascade do |t|
    t.string   "headline",        limit: 255
    t.string   "site",            limit: 255
    t.text     "body",            limit: 4294967295,                 null: false
    t.string   "url",             limit: 255
    t.integer  "status",          limit: 4,          default: 0,     null: false
    t.datetime "published_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "category_id",     limit: 4
    t.integer  "feature_type_id", limit: 4
    t.boolean  "needs_reindex",                      default: false
    t.text     "abstract",        limit: 65535
    t.string   "abstract_source", limit: 255
  end

  add_index "contentbase_contentshell", ["category_id"], name: "contentbase_contentshell_42dc49bc", using: :btree
  add_index "contentbase_contentshell", ["feature_type_id"], name: "index_contentbase_contentshell_on_feature_type_id", using: :btree
  add_index "contentbase_contentshell", ["published_at"], name: "index_contentbase_contentshell_on_published_at", using: :btree
  add_index "contentbase_contentshell", ["site"], name: "index_contentbase_contentshell_on_site", using: :btree
  add_index "contentbase_contentshell", ["status", "published_at"], name: "index_contentbase_contentshell_on_status_and_published_at", using: :btree
  add_index "contentbase_contentshell", ["status"], name: "index_contentbase_contentshell_on_status", using: :btree
  add_index "contentbase_contentshell", ["updated_at"], name: "index_contentbase_contentshell_on_updated_at", using: :btree

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

  create_table "data_points", force: :cascade do |t|
    t.string   "group_name", limit: 255
    t.string   "data_key",   limit: 255
    t.string   "notes",      limit: 255
    t.text     "data_value", limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "title",      limit: 255
  end

  add_index "data_points", ["data_key"], name: "index_data_points_on_data_key", using: :btree
  add_index "data_points", ["group_name"], name: "index_data_points_on_group", using: :btree
  add_index "data_points", ["updated_at"], name: "index_data_points_on_updated_at", using: :btree

  create_table "edition_slots", force: :cascade do |t|
    t.string   "item_type",  limit: 255
    t.integer  "item_id",    limit: 4
    t.integer  "edition_id", limit: 4
    t.integer  "position",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "edition_slots", ["edition_id"], name: "index_edition_slots_on_edition_id", using: :btree
  add_index "edition_slots", ["item_id", "item_type"], name: "index_edition_slots_on_item_id_and_item_type", using: :btree
  add_index "edition_slots", ["position"], name: "index_edition_slots_on_position", using: :btree

  create_table "editions", force: :cascade do |t|
    t.integer  "status",                      limit: 4
    t.datetime "published_at"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "title",                       limit: 255
    t.boolean  "shortlist_email_sent",                    default: false
    t.string   "slug",                        limit: 255
    t.boolean  "monday_shortlist_email_sent",             default: false
  end

  add_index "editions", ["published_at"], name: "index_editions_on_published_at", using: :btree
  add_index "editions", ["shortlist_email_sent"], name: "index_editions_on_shortlist_email_sent", using: :btree
  add_index "editions", ["slug"], name: "index_editions_on_slug", using: :btree
  add_index "editions", ["status", "published_at"], name: "index_editions_on_status_and_published_at", using: :btree
  add_index "editions", ["status"], name: "index_editions_on_status", using: :btree
  add_index "editions", ["updated_at"], name: "index_editions_on_updated_at", using: :btree

  create_table "eloqua_emails", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "description",         limit: 255
    t.string   "subject",             limit: 255
    t.string   "email",               limit: 255
    t.string   "html_template",       limit: 255
    t.string   "plain_text_template", limit: 255
    t.integer  "emailable_id",        limit: 4
    t.string   "emailable_type",      limit: 255
    t.boolean  "email_sent",                      default: false
    t.string   "email_type",          limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "attempts_made",       limit: 4,   default: 0
  end

  create_table "events", force: :cascade do |t|
    t.string   "headline",            limit: 255
    t.string   "slug",                limit: 255
    t.text     "body",                limit: 4294967295
    t.string   "event_type",          limit: 255
    t.string   "sponsor",             limit: 255
    t.string   "sponsor_url",         limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "is_all_day",                             default: false, null: false
    t.string   "location_name",       limit: 255
    t.string   "location_url",        limit: 255
    t.string   "rsvp_url",            limit: 255
    t.boolean  "show_map",                               default: true,  null: false
    t.string   "address_1",           limit: 255
    t.string   "address_2",           limit: 255
    t.string   "city",                limit: 255
    t.string   "state",               limit: 255
    t.string   "zip_code",            limit: 255
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "is_kpcc_event",                          default: false, null: false
    t.text     "archive_description", limit: 4294967295
    t.text     "teaser",              limit: 4294967295
    t.integer  "kpcc_program_id",     limit: 4
    t.integer  "status",              limit: 4,                          null: false
    t.boolean  "is_from_pij"
    t.string   "hashtag",             limit: 255
    t.integer  "category_id",         limit: 4
    t.integer  "asset_display_id",    limit: 4
    t.boolean  "needs_reindex",                          default: false
    t.text     "abstract",            limit: 65535
    t.string   "abstract_source",     limit: 255
  end

  add_index "events", ["asset_display_id"], name: "index_events_on_asset_display_id", using: :btree
  add_index "events", ["category_id"], name: "index_events_on_category_id", using: :btree
  add_index "events", ["event_type"], name: "index_events_event_on_etype", using: :btree
  add_index "events", ["is_kpcc_event"], name: "index_events_on_is_kpcc_event", using: :btree
  add_index "events", ["kpcc_program_id"], name: "events_event_7666a8c6", using: :btree
  add_index "events", ["slug"], name: "events_event_slug", using: :btree
  add_index "events", ["starts_at", "ends_at"], name: "index_events_event_on_starts_at_and_ends_at", using: :btree
  add_index "events", ["starts_at"], name: "index_events_on_starts_at", using: :btree
  add_index "events", ["status"], name: "index_events_on_status", using: :btree

  create_table "external_episode_segments", force: :cascade do |t|
    t.integer  "external_episode_id", limit: 4
    t.integer  "external_segment_id", limit: 4
    t.integer  "position",            limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "external_episode_segments", ["external_episode_id", "position"], name: "external_episode_segments_episode_id_position", using: :btree
  add_index "external_episode_segments", ["external_segment_id"], name: "index_external_episode_segments_on_external_segment_id", using: :btree

  create_table "external_episodes", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "summary",             limit: 16777215
    t.integer  "external_program_id", limit: 4
    t.string   "external_id",         limit: 255
    t.datetime "air_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "external_episodes", ["air_date"], name: "index_external_episodes_on_air_date", using: :btree
  add_index "external_episodes", ["external_program_id", "external_id"], name: "index_external_episodes_on_external_program_id_and_external_id", using: :btree

  create_table "external_programs", force: :cascade do |t|
    t.string   "slug",             limit: 255,      null: false
    t.string   "title",            limit: 255,      null: false
    t.text     "teaser",           limit: 16777215
    t.text     "description",      limit: 16777215
    t.string   "host",             limit: 255
    t.string   "organization",     limit: 50
    t.string   "airtime",          limit: 255
    t.string   "air_status",       limit: 255,      null: false
    t.string   "podcast_url",      limit: 255
    t.text     "sidebar",          limit: 16777215
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "source",           limit: 255
    t.integer  "external_id",      limit: 4
    t.integer  "days_to_expiry",   limit: 4
    t.string   "description_text", limit: 255
    t.string   "phone_number",     limit: 255
    t.boolean  "is_featured"
  end

  add_index "external_programs", ["air_status"], name: "index_external_programs_on_air_status", using: :btree
  add_index "external_programs", ["days_to_expiry"], name: "index_external_programs_on_days_to_expiry", using: :btree
  add_index "external_programs", ["slug"], name: "index_external_programs_on_slug", using: :btree
  add_index "external_programs", ["source", "external_id"], name: "index_external_programs_on_source_and_external_id", using: :btree
  add_index "external_programs", ["title"], name: "index_external_programs_on_title", using: :btree

  create_table "external_segments", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "teaser",              limit: 16777215
    t.integer  "external_program_id", limit: 4
    t.string   "external_id",         limit: 255
    t.string   "external_url",        limit: 255
    t.datetime "published_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "external_segments", ["external_program_id", "external_id"], name: "index_external_segments_on_external_program_id_and_external_id", using: :btree
  add_index "external_segments", ["published_at"], name: "index_external_segments_on_published_at", using: :btree

  create_table "flatpages_flatpage", force: :cascade do |t|
    t.string   "path",           limit: 255,                        null: false
    t.string   "title",          limit: 255,                        null: false
    t.text     "content",        limit: 4294967295,                 null: false
    t.text     "extra_head",     limit: 4294967295,                 null: false
    t.text     "extra_tail",     limit: 4294967295,                 null: false
    t.datetime "updated_at"
    t.text     "description",    limit: 4294967295,                 null: false
    t.string   "redirect_to",    limit: 255
    t.boolean  "is_public",                         default: false, null: false
    t.datetime "created_at",                                        null: false
    t.string   "template",       limit: 255,                        null: false
    t.text     "extra_metahead", limit: 65535
  end

  add_index "flatpages_flatpage", ["is_public"], name: "index_flatpages_flatpage_on_is_public", using: :btree
  add_index "flatpages_flatpage", ["path"], name: "django_flatpage_url", using: :btree
  add_index "flatpages_flatpage", ["updated_at"], name: "index_flatpages_flatpage_on_updated_at", using: :btree

  create_table "landing_page_contents", force: :cascade do |t|
    t.integer  "position",        limit: 4
    t.integer  "article_id",      limit: 4
    t.string   "article_type",    limit: 255
    t.integer  "landing_page_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "landing_page_reporters", force: :cascade do |t|
    t.integer  "bio_id",          limit: 4
    t.integer  "landing_page_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "landing_pages", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",        limit: 255
  end

  create_table "layout_breakingnewsalert", force: :cascade do |t|
    t.string   "headline",                 limit: 255,                        null: false
    t.string   "alert_type",               limit: 255,                        null: false
    t.boolean  "email_sent",                                  default: false, null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.text     "teaser",                   limit: 4294967295,                 null: false
    t.string   "alert_url",                limit: 200,                        null: false
    t.boolean  "send_email",                                  default: false, null: false
    t.boolean  "visible",                                                     null: false
    t.boolean  "send_mobile_notification",                    default: false, null: false
    t.boolean  "mobile_notification_sent",                    default: false, null: false
    t.integer  "status",                   limit: 4
    t.datetime "published_at"
  end

  add_index "layout_breakingnewsalert", ["alert_type"], name: "index_layout_breakingnewsalert_on_alert_type", using: :btree
  add_index "layout_breakingnewsalert", ["email_sent"], name: "index_layout_breakingnewsalert_on_email_sent", using: :btree
  add_index "layout_breakingnewsalert", ["mobile_notification_sent"], name: "index_layout_breakingnewsalert_on_mobile_notification_sent", using: :btree
  add_index "layout_breakingnewsalert", ["published_at"], name: "index_layout_breakingnewsalert_on_published_at", using: :btree
  add_index "layout_breakingnewsalert", ["status", "published_at"], name: "index_layout_breakingnewsalert_on_status_and_published_at", using: :btree
  add_index "layout_breakingnewsalert", ["visible"], name: "index_layout_breakingnewsalert_on_visible", using: :btree

  create_table "layout_homepage", force: :cascade do |t|
    t.string   "base",                limit: 255
    t.datetime "published_at"
    t.integer  "status",              limit: 4,   null: false
    t.integer  "missed_it_bucket_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "layout_homepage", ["missed_it_bucket_id"], name: "layout_homepage_d12628ce", using: :btree
  add_index "layout_homepage", ["published_at"], name: "index_layout_homepage_on_published_at", using: :btree
  add_index "layout_homepage", ["status", "published_at"], name: "index_layout_homepage_on_status_and_published_at", using: :btree
  add_index "layout_homepage", ["updated_at"], name: "index_layout_homepage_on_updated_at", using: :btree

  create_table "layout_homepagecontent", force: :cascade do |t|
    t.integer "homepage_id",   limit: 4,                null: false
    t.integer "content_id",    limit: 4
    t.integer "position",      limit: 4,   default: 99, null: false
    t.string  "content_type",  limit: 255
    t.string  "homepage_type", limit: 255
    t.string  "asset_scheme",  limit: 255
  end

  add_index "layout_homepagecontent", ["content_id", "content_type"], name: "index_layout_homepagecontent_on_content_id_and_content_type", using: :btree
  add_index "layout_homepagecontent", ["homepage_id"], name: "layout_homepagecontent_35da0e60", using: :btree

  create_table "list_items", force: :cascade do |t|
    t.integer  "list_id",    limit: 4
    t.integer  "item_id",    limit: 4
    t.string   "item_type",  limit: 255
    t.integer  "position",   limit: 4,   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "list_items", ["item_type", "item_id"], name: "index_list_items_on_item_type_and_item_id", using: :btree
  add_index "list_items", ["list_id"], name: "index_list_items_on_list_id", using: :btree

  create_table "lists", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.string   "context",      limit: 255
    t.integer  "position",     limit: 4,   default: 0
    t.integer  "status",       limit: 4
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "published_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "content_type", limit: 255
    t.integer  "category_id",  limit: 4
  end

  add_index "lists", ["ends_at"], name: "index_lists_on_ends_at", using: :btree
  add_index "lists", ["published_at"], name: "index_lists_on_published_at", using: :btree
  add_index "lists", ["starts_at"], name: "index_lists_on_starts_at", using: :btree
  add_index "lists", ["status"], name: "index_lists_on_status", using: :btree

  create_table "media_audio", force: :cascade do |t|
    t.integer  "size",         limit: 4
    t.integer  "duration",     limit: 4
    t.integer  "content_id",   limit: 4
    t.text     "description",  limit: 4294967295
    t.string   "byline",       limit: 255
    t.integer  "position",     limit: 4,          default: 0, null: false
    t.string   "content_type", limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "url",          limit: 512
    t.integer  "status",       limit: 4
  end

  add_index "media_audio", ["content_id", "content_type"], name: "index_media_audio_on_content_id_and_content_type", using: :btree
  add_index "media_audio", ["position"], name: "index_media_audio_on_position", using: :btree
  add_index "media_audio", ["status"], name: "index_media_audio_on_status", using: :btree

  create_table "media_document", force: :cascade do |t|
    t.string   "document_file", limit: 100,        null: false
    t.string   "title",         limit: 140,        null: false
    t.text     "description",   limit: 4294967295, null: false
    t.string   "source",        limit: 140,        null: false
    t.datetime "uploaded_at",                      null: false
  end

  create_table "media_image", force: :cascade do |t|
    t.text     "caption",    limit: 4294967295, null: false
    t.string   "credit",     limit: 150,        null: false
    t.datetime "created_at",                    null: false
  end

  create_table "media_imageinstance", force: :cascade do |t|
    t.string  "image_file",     limit: 100, null: false
    t.string  "image_type",     limit: 10,  null: false
    t.integer "instance_of_id", limit: 4,   null: false
  end

  add_index "media_imageinstance", ["instance_of_id"], name: "media_imageinstance_29b6bd08", using: :btree

  create_table "media_related", force: :cascade do |t|
    t.integer "content_id",   limit: 4,               null: false
    t.integer "related_id",   limit: 4,               null: false
    t.string  "content_type", limit: 255
    t.string  "related_type", limit: 255
    t.integer "position",     limit: 4,   default: 0, null: false
  end

  add_index "media_related", ["content_id", "content_type"], name: "index_media_related_on_content_id_and_content_type", using: :btree
  add_index "media_related", ["related_id", "related_type"], name: "index_media_related_on_related_id_and_related_type", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "email",         limit: 255
    t.boolean  "email_sent"
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.string   "name",          limit: 255
    t.boolean  "pfs_selected"
    t.integer  "pledge_amount", limit: 4
    t.string   "pledge_id",     limit: 255
    t.string   "pledge_token",  limit: 255
    t.string   "pledge_type",   limit: 255
    t.string   "record_source", limit: 255
    t.integer  "views_left",    limit: 4
    t.string   "member_id",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "members", ["email"], name: "index_members_on_email", using: :btree
  add_index "members", ["member_id"], name: "index_members_on_member_id", using: :btree
  add_index "members", ["pledge_token"], name: "index_members_on_pledge_token", using: :btree

  create_table "news_story", force: :cascade do |t|
    t.string   "headline",         limit: 255
    t.string   "slug",             limit: 255
    t.string   "news_agency",      limit: 255
    t.text     "teaser",           limit: 4294967295
    t.text     "body",             limit: 4294967295
    t.datetime "published_at"
    t.string   "source",           limit: 255
    t.integer  "status",           limit: 4,                          null: false
    t.string   "short_headline",   limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "category_id",      limit: 4
    t.boolean  "is_from_pij",                         default: false, null: false
    t.integer  "feature_type_id",  limit: 4
    t.integer  "asset_display_id", limit: 4
    t.boolean  "needs_reindex",                       default: false
    t.text     "abstract",         limit: 65535
    t.string   "abstract_source",  limit: 255
  end

  add_index "news_story", ["asset_display_id"], name: "index_news_story_on_asset_display_id", using: :btree
  add_index "news_story", ["category_id"], name: "news_story_42dc49bc", using: :btree
  add_index "news_story", ["feature_type_id"], name: "index_news_story_on_feature_type_id", using: :btree
  add_index "news_story", ["published_at"], name: "news_story_published_at", using: :btree
  add_index "news_story", ["source"], name: "index_news_story_on_source", using: :btree
  add_index "news_story", ["status", "published_at"], name: "index_news_story_on_status_and_published_at", using: :btree
  add_index "news_story", ["status"], name: "index_news_story_on_status", using: :btree
  add_index "news_story", ["updated_at"], name: "index_news_story_on_updated_at", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "resource",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "permissions", ["resource"], name: "index_permissions_on_resource_and_action", using: :btree

  create_table "pij_query", force: :cascade do |t|
    t.string   "slug",          limit: 255
    t.string   "headline",      limit: 255
    t.text     "teaser",        limit: 4294967295
    t.text     "body",          limit: 4294967295
    t.string   "query_type",    limit: 255
    t.datetime "published_at"
    t.boolean  "is_featured",                      default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "pin_query_id",  limit: 255
    t.integer  "status",        limit: 4
    t.boolean  "needs_reindex",                    default: false
    t.text     "abstract",      limit: 65535
  end

  add_index "pij_query", ["is_featured"], name: "index_pij_query_on_is_featured", using: :btree
  add_index "pij_query", ["published_at"], name: "index_pij_query_on_is_active_and_published_at", using: :btree
  add_index "pij_query", ["query_type"], name: "index_pij_query_on_query_type", using: :btree
  add_index "pij_query", ["slug"], name: "slug", unique: true, using: :btree
  add_index "pij_query", ["status"], name: "index_pij_query_on_status", using: :btree

  create_table "pledge_drives", force: :cascade do |t|
    t.datetime "starts_at",                                 null: false
    t.datetime "ends_at",                                   null: false
    t.boolean  "enabled",                   default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "current_dollars", limit: 4
    t.integer  "goal_dollars",    limit: 4
  end

  add_index "pledge_drives", ["ends_at"], name: "index_pledge_drives_on_ends_at", using: :btree
  add_index "pledge_drives", ["starts_at"], name: "index_pledge_drives_on_starts_at", using: :btree

  create_table "pmp_contents", force: :cascade do |t|
    t.integer  "content_id",     limit: 4
    t.string   "content_type",   limit: 255
    t.string   "guid",           limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "pmp_content_id", limit: 4
    t.string   "profile",        limit: 255
    t.string   "title",          limit: 255
  end

  create_table "podcasts", force: :cascade do |t|
    t.string   "slug",               limit: 255
    t.string   "title",              limit: 255
    t.string   "url",                limit: 255
    t.string   "podcast_url",        limit: 255
    t.string   "itunes_url",         limit: 255
    t.text     "description",        limit: 16777215
    t.string   "image_url",          limit: 255
    t.string   "author",             limit: 255
    t.string   "keywords",           limit: 255
    t.string   "duration",           limit: 255
    t.boolean  "is_listed",                           default: false, null: false
    t.integer  "source_id",          limit: 4
    t.integer  "category_id",        limit: 4
    t.string   "item_type",          limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "source_type",        limit: 255
    t.integer  "itunes_category_id", limit: 4
  end

  add_index "podcasts", ["category_id"], name: "podcasts_podcast_42dc49bc", using: :btree
  add_index "podcasts", ["is_listed"], name: "index_podcasts_on_is_listed", using: :btree
  add_index "podcasts", ["slug"], name: "slug", unique: true, using: :btree
  add_index "podcasts", ["source_id"], name: "podcasts_podcast_7eef53e3", using: :btree
  add_index "podcasts", ["title"], name: "index_podcasts_on_title", using: :btree

  create_table "press_releases", force: :cascade do |t|
    t.string   "short_title", limit: 255
    t.string   "slug",        limit: 255
    t.string   "title",       limit: 255
    t.text     "body",        limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "press_releases", ["created_at"], name: "index_press_releases_on_created_at", using: :btree
  add_index "press_releases", ["slug"], name: "press_releases_release_slug", using: :btree

  create_table "program_articles", force: :cascade do |t|
    t.integer "position",     limit: 4
    t.integer "article_id",   limit: 4
    t.string  "article_type", limit: 255
    t.integer "program_id",   limit: 4
  end

  add_index "program_articles", ["article_id", "article_type"], name: "index_program_articles_on_article_id_and_article_type", using: :btree
  add_index "program_articles", ["position"], name: "index_program_articles_on_position", using: :btree
  add_index "program_articles", ["program_id"], name: "index_program_articles_on_program_id", using: :btree

  create_table "program_reporters", force: :cascade do |t|
    t.integer "bio_id",     limit: 4
    t.integer "program_id", limit: 4
  end

  add_index "program_reporters", ["bio_id"], name: "index_program_reporters_on_bio_id", using: :btree
  add_index "program_reporters", ["program_id"], name: "index_program_reporters_on_program_id", using: :btree

  create_table "programs_kpccprogram", force: :cascade do |t|
    t.string   "slug",                    limit: 255,                      null: false
    t.string   "title",                   limit: 255,                      null: false
    t.text     "teaser",                  limit: 16777215
    t.text     "description",             limit: 16777215
    t.string   "host",                    limit: 255
    t.string   "airtime",                 limit: 255
    t.string   "air_status",              limit: 255,                      null: false
    t.text     "sidebar",                 limit: 16777215
    t.boolean  "is_segmented",                             default: true,  null: false
    t.integer  "blog_id",                 limit: 4
    t.string   "audio_dir",               limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.boolean  "is_featured",                              default: false, null: false
    t.integer  "quote_id",                limit: 4
    t.string   "newsletter_form_name",    limit: 255
    t.string   "newsletter_form_caption", limit: 255
    t.string   "newsletter_form_heading", limit: 255
    t.string   "description_text",        limit: 255
    t.string   "phone_number",            limit: 255
  end

  add_index "programs_kpccprogram", ["air_status"], name: "index_programs_kpccprogram_on_air_status", using: :btree
  add_index "programs_kpccprogram", ["blog_id"], name: "programs_kpccprogram_472bc96c", using: :btree
  add_index "programs_kpccprogram", ["is_featured"], name: "index_programs_kpccprogram_on_is_featured", using: :btree
  add_index "programs_kpccprogram", ["quote_id"], name: "index_programs_kpccprogram_on_quote_id", using: :btree
  add_index "programs_kpccprogram", ["slug"], name: "index_programs_kpccprogram_on_slug", using: :btree
  add_index "programs_kpccprogram", ["title"], name: "index_programs_kpccprogram_on_title", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.text     "text",           limit: 65535
    t.string   "source_name",    limit: 255
    t.string   "source_context", limit: 255
    t.integer  "content_id",     limit: 4
    t.string   "content_type",   limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "quotes", ["content_id", "content_type"], name: "index_quotes_on_content_id_and_content_type", using: :btree
  add_index "quotes", ["created_at"], name: "index_quotes_on_created_at", using: :btree

  create_table "recurring_schedule_rules", force: :cascade do |t|
    t.text     "schedule_hash",     limit: 16777215
    t.integer  "interval",          limit: 4
    t.string   "days",              limit: 255
    t.string   "start_time",        limit: 255
    t.string   "end_time",          limit: 255
    t.integer  "program_id",        limit: 4
    t.string   "program_type",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "soft_start_offset", limit: 4
  end

  add_index "recurring_schedule_rules", ["program_id", "program_type"], name: "index_recurring_schedule_rules_on_program_id_and_program_type", using: :btree

  create_table "related_links", force: :cascade do |t|
    t.string   "title",        limit: 255, default: ""
    t.string   "url",          limit: 255
    t.string   "link_type",    limit: 255
    t.integer  "content_id",   limit: 4
    t.string   "content_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "related_links", ["content_id", "content_type"], name: "index_related_links_on_content_id_and_content_type", using: :btree
  add_index "related_links", ["link_type"], name: "index_related_links_on_link_type", using: :btree

  create_table "remote_articles", force: :cascade do |t|
    t.string   "headline",     limit: 255
    t.text     "teaser",       limit: 4294967295
    t.datetime "published_at"
    t.string   "url",          limit: 512
    t.string   "article_id",   limit: 255
    t.boolean  "is_new",                          default: true, null: false
    t.string   "source",       limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "news_agency",  limit: 255
  end

  add_index "remote_articles", ["article_id", "source"], name: "index_remote_articles_on_article_id_and_source", unique: true, using: :btree
  add_index "remote_articles", ["published_at"], name: "index_remote_articles_on_published_at", using: :btree
  add_index "remote_articles", ["source"], name: "index_remote_articles_on_source", using: :btree

  create_table "schedule_occurrences", force: :cascade do |t|
    t.string   "event_title",                limit: 255
    t.string   "info_url",                   limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "program_id",                 limit: 4
    t.string   "program_type",               limit: 255
    t.integer  "recurring_schedule_rule_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "soft_starts_at"
  end

  add_index "schedule_occurrences", ["program_id", "program_type"], name: "index_schedule_occurrences_on_program_id_and_program_type", using: :btree
  add_index "schedule_occurrences", ["recurring_schedule_rule_id"], name: "index_schedule_occurrences_on_recurring_schedule_rule_id", using: :btree
  add_index "schedule_occurrences", ["starts_at", "ends_at"], name: "index_schedule_occurrences_on_starts_at_and_ends_at", using: :btree
  add_index "schedule_occurrences", ["starts_at"], name: "index_schedule_occurrences_on_starts_at", using: :btree
  add_index "schedule_occurrences", ["updated_at"], name: "index_schedule_occurrences_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "context",    limit: 255
    t.text     "value",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "shows_episode", force: :cascade do |t|
    t.integer  "show_id",             limit: 4,                          null: false
    t.datetime "air_date"
    t.string   "headline",            limit: 255
    t.text     "teaser",              limit: 4294967295
    t.datetime "published_at"
    t.integer  "status",              limit: 4,                          null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.text     "body",                limit: 65535
    t.integer  "asset_display_id",    limit: 4
    t.integer  "original_segment_id", limit: 4
    t.boolean  "needs_reindex",                          default: false
    t.text     "abstract",            limit: 65535
    t.string   "short_headline",      limit: 255
    t.integer  "feature_type_id",     limit: 4
  end

  add_index "shows_episode", ["air_date"], name: "index_shows_episode_on_air_date", using: :btree
  add_index "shows_episode", ["asset_display_id"], name: "index_shows_episode_on_asset_display_id", using: :btree
  add_index "shows_episode", ["original_segment_id"], name: "index_shows_episode_on_original_segment_id", using: :btree
  add_index "shows_episode", ["published_at"], name: "index_shows_episode_on_published_at", using: :btree
  add_index "shows_episode", ["show_id"], name: "shows_episode_show_id", using: :btree
  add_index "shows_episode", ["status", "published_at"], name: "index_shows_episode_on_status_and_published_at", using: :btree
  add_index "shows_episode", ["status"], name: "index_shows_episode_on_status", using: :btree

  create_table "shows_rundown", force: :cascade do |t|
    t.integer "episode_id",   limit: 4,   null: false
    t.integer "content_id",   limit: 4,   null: false
    t.integer "position",     limit: 4,   null: false
    t.string  "content_type", limit: 255
  end

  add_index "shows_rundown", ["content_id"], name: "shows_rundown_segment_id", using: :btree
  add_index "shows_rundown", ["episode_id"], name: "shows_rundown_episode_id", using: :btree
  add_index "shows_rundown", ["position"], name: "index_shows_rundown_on_segment_order", using: :btree

  create_table "shows_segment", force: :cascade do |t|
    t.integer  "show_id",          limit: 4,                          null: false
    t.string   "headline",         limit: 255
    t.string   "slug",             limit: 255
    t.text     "teaser",           limit: 4294967295
    t.text     "body",             limit: 4294967295
    t.datetime "created_at",                                          null: false
    t.integer  "status",           limit: 4,                          null: false
    t.string   "short_headline",   limit: 255
    t.datetime "published_at"
    t.datetime "updated_at",                                          null: false
    t.integer  "category_id",      limit: 4
    t.boolean  "is_from_pij"
    t.integer  "feature_type_id",  limit: 4
    t.integer  "asset_display_id", limit: 4
    t.boolean  "needs_reindex",                       default: false
    t.text     "abstract",         limit: 65535
    t.string   "abstract_source",  limit: 255
  end

  add_index "shows_segment", ["asset_display_id"], name: "index_shows_segment_on_asset_display_id", using: :btree
  add_index "shows_segment", ["category_id"], name: "shows_segment_42dc49bc", using: :btree
  add_index "shows_segment", ["feature_type_id"], name: "index_shows_segment_on_feature_type_id", using: :btree
  add_index "shows_segment", ["published_at"], name: "index_shows_segment_on_published_at", using: :btree
  add_index "shows_segment", ["show_id"], name: "shows_segment_show_id", using: :btree
  add_index "shows_segment", ["slug"], name: "shows_segment_slug", using: :btree
  add_index "shows_segment", ["status", "published_at"], name: "index_shows_segment_on_status_and_published_at", using: :btree
  add_index "shows_segment", ["status"], name: "index_shows_segment_on_status", using: :btree
  add_index "shows_segment", ["updated_at"], name: "index_shows_segment_on_updated_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.string   "taggable_type", limit: 255
    t.integer  "taggable_id",   limit: 4
    t.integer  "tag_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "taggit_tag", force: :cascade do |t|
    t.string  "name",  limit: 100, null: false
    t.string  "slug",  limit: 100, null: false
    t.integer "wp_id", limit: 4
  end

  add_index "taggit_tag", ["slug"], name: "slug", unique: true, using: :btree

  create_table "taggit_taggeditem", force: :cascade do |t|
    t.integer "tag_id",                 limit: 4,                        null: false
    t.integer "content_id",             limit: 4,                        null: false
    t.integer "django_content_type_id", limit: 4
    t.string  "content_type",           limit: 20, default: "BlogEntry"
  end

  add_index "taggit_taggeditem", ["content_id"], name: "index_taggit_taggeditem_on_content_id", using: :btree
  add_index "taggit_taggeditem", ["content_id"], name: "taggit_taggeditem_829e37fd", using: :btree
  add_index "taggit_taggeditem", ["content_type", "content_id"], name: "index_taggit_taggeditem_on_content_type_and_content_id", using: :btree
  add_index "taggit_taggeditem", ["django_content_type_id"], name: "taggit_taggeditem_e4470c6e", using: :btree
  add_index "taggit_taggeditem", ["tag_id"], name: "taggit_taggeditem_3747b463", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "slug",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image",       limit: 255
    t.string   "tag_type",    limit: 255,   default: "Keyword"
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.string   "pmp_alias",   limit: 255
  end

  add_index "tags", ["created_at"], name: "index_tags_on_created_at", using: :btree
  add_index "tags", ["slug"], name: "index_tags_on_slug", using: :btree

  create_table "user_permissions", force: :cascade do |t|
    t.integer  "admin_user_id", limit: 4
    t.integer  "permission_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "user_permissions", ["admin_user_id"], name: "index_admin_user_permissions_on_admin_user_id", using: :btree
  add_index "user_permissions", ["permission_id"], name: "index_admin_user_permissions_on_permission_id", using: :btree

  create_table "users_userprofile", force: :cascade do |t|
    t.integer  "userid",     limit: 4,   null: false
    t.string   "nickname",   limit: 50,  null: false
    t.string   "firstname",  limit: 50
    t.string   "lastname",   limit: 50
    t.string   "location",   limit: 120
    t.string   "image_file", limit: 100
    t.string   "email",      limit: 75
    t.datetime "last_login"
  end

  add_index "users_userprofile", ["nickname"], name: "nickname", unique: true, using: :btree
  add_index "users_userprofile", ["userid"], name: "userid", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.integer  "version_number", limit: 4
    t.string   "versioned_type", limit: 255
    t.integer  "versioned_id",   limit: 4
    t.integer  "user_id",        limit: 4
    t.text     "description",    limit: 16777215
    t.datetime "created_at"
    t.text     "object_changes", limit: 16777215
  end

  add_index "versions", ["created_at"], name: "index_versions_on_created_at", using: :btree
  add_index "versions", ["user_id"], name: "index_versions_on_user_id", using: :btree
  add_index "versions", ["version_number"], name: "index_versions_on_version_number", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

  create_table "verticals", force: :cascade do |t|
    t.string   "slug",                          limit: 255
    t.integer  "category_id",                   limit: 4
    t.string   "title",                         limit: 255
    t.text     "description",                   limit: 65535
    t.integer  "featured_interactive_style_id", limit: 4
    t.integer  "blog_id",                       limit: 4
    t.integer  "quote_id",                      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "verticals", ["blog_id"], name: "index_verticals_on_blog_id", using: :btree
  add_index "verticals", ["category_id"], name: "index_verticals_on_category_id", using: :btree
  add_index "verticals", ["quote_id"], name: "index_verticals_on_quote_id", using: :btree
  add_index "verticals", ["slug"], name: "index_verticals_on_slug", using: :btree

end
