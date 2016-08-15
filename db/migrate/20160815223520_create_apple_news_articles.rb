class CreateAppleNewsArticles < ActiveRecord::Migration
  def change
    create_table :apple_news_articles do |t|
      t.belongs_to :record, index: true
      t.string :record_type, index: true
      t.string :uuid
      t.string :revision
      t.timestamps null: false
    end
  end
end
