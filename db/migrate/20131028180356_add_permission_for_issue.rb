class AddPermissionForIssue < ActiveRecord::Migration
  def up
     Permission.create(resource: "Issue")
  end

  def down
    Permission.destroy_all resource: "Issue"
  end
end
