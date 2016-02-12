class CreatePledgeDrivesPermission < ActiveRecord::Migration
  def up
    Permission.where(resource: "PledgeDrive").first_or_create
  end
  def down
    Permission.where(resource: "PledgeDrive").destroy_all
  end
end