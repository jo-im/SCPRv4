class IndexAllRemoteArticles < ActiveRecord::Migration
  def up
    ## This method goes by batches of 1000 and runs the block
    ## on every element of each batch
    RemoteArticle.find_each do |remote_article|
      remote_article.__elasticsearch__.index_document
    end
  end
  def down
    RemoteArticle.find_each do |remote_article|
      remote_article.__elasticsearch__.delete_document
    end
  end
end
