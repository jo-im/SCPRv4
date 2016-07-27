class AddBroadcastContentPermission < ActiveRecord::Migration
  def up
    Permission.where(resource: "BroadcastContent").first_or_create
  end
  def down
    Permission.where(resource: "BroadcastContent").destroy_all
  end
end
