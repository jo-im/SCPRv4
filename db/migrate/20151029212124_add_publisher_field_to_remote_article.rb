class AddPublisherFieldToRemoteArticle < ActiveRecord::Migration
  def change
    add_column :remote_articles, :publisher, :string, index: true
  end
end
