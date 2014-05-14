class RemoveChrArticleFromRemoteArticles < ActiveRecord::Migration
  def up
    RemoteArticle.where(source: "chr").destroy_all
  end

  def down
  end
end
