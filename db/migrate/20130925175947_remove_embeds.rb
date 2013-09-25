class RemoveEmbeds < ActiveRecord::Migration
  def up
    drop_table :embeds
  end

  def down
    create_table "embeds", :force => true do |t|
      t.string   "title"
      t.string   "content_type"
      t.integer  "content_id"
      t.string   "url"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    add_index "embeds", ["content_type", "content_id"], :name => "index_embeds_on_content_type_and_content_id"
  end
end
