class RemoveBroadcastContentPermission < ActiveRecord::Migration
  def up
    Permission.where(resource: "BroadcastContent").delete_all
  end
  def down
    Permission.where(resource: "BroadcastContent").first_or_create
  end
end
