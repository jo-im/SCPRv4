class RemoveOldIndeces < ActiveRecord::Migration
  def up
    remove_index "assethost_contentasset", :name => "content_type_id"
    remove_index "assethost_contentasset", :name => "index_assethost_contentasset_on_content_id"

    remove_index "blogs_blog", :name => "name"
    add_index "blogs_blog", "name"

    remove_index "contentbase_contentalarm", :name => "index_contentbase_contentalarm_on_content_id"

    remove_index "contentbase_contentbyline", :name => "index_contentbase_contentbyline_on_content_id"
    remove_index "contentbase_contentbyline", :name => "content_key"


    remove_index "contentbase_featuredcomment", :name => "index_contentbase_featuredcomment_on_content_id"

    remove_index "contentbase_misseditcontent", :name => "index_contentbase_misseditcontent_on_content_id"

    remove_index "layout_homepagecontent", :name => "index_layout_homepagecontent_on_content_id"

    remove_index "media_audio", :name => "index_media_audio_on_content_id"
    remove_index "media_audio", :name => "media_audio_content_type_id_569dcfe00f4d911"
    remove_index "media_audio", :name => "index_media_audio_on_mp3"

    remove_index "media_related", :name => "index_media_related_on_content_id"
    remove_index "media_related", :name => "index_media_related_on_related_id"
  end

  def down
    add_index "assethost_contentasset", ["content_id"], :name => "content_type_id"
    add_index "assethost_contentasset", ["content_id"], :name => "index_assethost_contentasset_on_content_id"

    remove_index "blogs_blog", "name"
    add_index "blogs_blog", ["name"], :name => "name", :unique => true

    add_index "contentbase_contentalarm", ["content_id"], :name => "index_contentbase_contentalarm_on_content_id"

    add_index "contentbase_contentbyline", ["content_id"], :name => "content_key"
    add_index "contentbase_contentbyline", ["content_id"], :name => "index_contentbase_contentbyline_on_content_id"

    add_index "contentbase_featuredcomment", ["content_id"], :name => "index_contentbase_featuredcomment_on_content_id"

    add_index "contentbase_misseditcontent", ["content_id"], :name => "index_contentbase_misseditcontent_on_content_id"

    add_index "layout_homepagecontent", ["content_id"], :name => "index_layout_homepagecontent_on_content_id"

    add_index "media_audio", ["content_id"], :name => "index_media_audio_on_content_id"
    add_index "media_audio", ["content_id"], :name => "media_audio_content_type_id_569dcfe00f4d911"
    add_index "media_audio", ["mp3"], :name => "index_media_audio_on_mp3"

    add_index "media_related", ["content_id"], :name => "index_media_related_on_content_id"
    add_index "media_related", ["related_id"], :name => "index_media_related_on_related_id"
  end
end
