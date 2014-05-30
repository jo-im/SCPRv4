class FixVersionIndex < ActiveRecord::Migration
  def change
    remove_index :versions, column: ["created_at", "user_id"]
    add_index :versions, ["user_id"]
  end
end
