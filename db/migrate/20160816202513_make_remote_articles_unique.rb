class MakeRemoteArticlesUnique < ActiveRecord::Migration
  def up
    RemoteArticle.duplicates.delete_all
    remove_index "remote_articles", ["article_id", "source"]
    add_index "remote_articles", ["article_id", "source"], name: "index_remote_articles_on_article_id_and_source", using: :btree, unique: true
  end
  def down
    remove_index "remote_articles", ["article_id", "source"]
    add_index "remote_articles", ["article_id", "source"], name: "index_remote_articles_on_article_id_and_source", using: :btree
  end
end
