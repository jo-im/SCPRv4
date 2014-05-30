class IndexCleanup2 < ActiveRecord::Migration
  def change
    remove_index "assethost_contentasset", column: ["content_type", "content_id"]
    add_index "assethost_contentasset", ["content_id", "content_type"]

    remove_index "bios_bio", column: ["is_public", "last_name"]
    add_index "bios_bio", ["last_name", "is_public"]

    remove_index "blogs_blogauthor", name: "blogs_blog_authors_blog_id_579f20695740dd5e_uniq"
    add_index "blogs_blogauthor", ["author_id", "blog_id"]

    remove_index "contentbase_contentalarm", column: ["content_type", "content_id"]
    add_index "contentbase_contentalarm", ["content_id", "content_type"]

    remove_index "contentbase_contentbyline", column: ["content_type", "content_id"]
    add_index "contentbase_contentbyline", ["content_id", "content_type"]

    remove_index "edition_slots", column: ["item_type", "item_id"]
    add_index "edition_slots", ["item_id", "item_type"]

    remove_index "layout_homepagecontent", column: ["content_type", "content_id"]
    add_index "layout_homepagecontent", ["content_id", "content_type"]

    remove_index "media_audio", column: ["content_type", "content_id"]
    add_index "media_audio", ["content_id", "content_type"]

    remove_index "media_related", column: ["content_type", "content_id"]
    add_index "media_related", ["content_id", "content_type"]
    remove_index "media_related", column: ["related_type", "related_id"]
    add_index "media_related", ["related_id", "related_type"]

    remove_index "recurring_schedule_rules", column: ["program_type", "program_id"]
    add_index "recurring_schedule_rules", ["program_id", "program_type"]

    remove_index "related_links", name: "index_media_link_on_content_type_and_content_id"
    add_index "related_links", ["content_id", "content_type"]

    remove_index "remote_articles", column: ["source", "article_id"]
    add_index "remote_articles", ["article_id", "source"]

    remove_index "schedule_occurrences", column: ["program_type", "program_id"]
    add_index "schedule_occurrences", ["program_id", "program_type"]

    remove_index "taggings", column: ["taggable_type", "taggable_id"]
    add_index "taggings", ["taggable_id", "taggable_type"]

    remove_index "versions", column: ["versioned_type", "versioned_id"]
    add_index "versions", ["versioned_id", "versioned_type"]
  end
end
