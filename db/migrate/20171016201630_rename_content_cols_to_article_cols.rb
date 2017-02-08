class RenameContentColsToArticleCols < ActiveRecord::Migration
  def change
    if !column_exists?(:landing_page_contents, :article_id) && !column_exists?(:landing_page_contents, :article_type)
      rename_column :landing_page_contents, :content_id, :article_id
      rename_column :landing_page_contents, :content_type, :article_type
    end
  end
end
