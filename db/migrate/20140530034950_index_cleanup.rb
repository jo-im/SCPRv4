class IndexCleanup < ActiveRecord::Migration
  def change
    remove_index :versions, column: ["created_at"]
    remove_index :versions, column: ["user_id", "created_at"]
    remove_index :versions, column: ["user_id"]

    add_index :versions, ["created_at", "user_id"]
  end
end
