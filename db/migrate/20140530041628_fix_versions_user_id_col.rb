class FixVersionsUserIdCol < ActiveRecord::Migration
  def up
    change_column :versions, :user_id, :integer
  end

  def down
    change_column :versions, :user_id, :string
  end
end
