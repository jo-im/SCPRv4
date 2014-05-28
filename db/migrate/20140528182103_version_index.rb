class VersionIndex < ActiveRecord::Migration
  def change
    add_index :versions, [:user_id, :created_at]
  end
end
