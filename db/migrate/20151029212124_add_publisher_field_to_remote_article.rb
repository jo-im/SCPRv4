class AddPublisherFieldToRemoteArticle < ActiveRecord::Migration
  def change
    add_column :remote_articles, :news_agency, :string, index: true
  end
end
