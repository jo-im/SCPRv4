class IncreaseRemoteArticleUrlLimit < ActiveRecord::Migration
  def up
    change_column :remote_articles, :url, :string, limit: 512
  end
  def down
    change_column :remote_articles, :url, :string, limit: 512
  end
end
