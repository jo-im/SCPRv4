class RemoveIssuePermission < ActiveRecord::Migration
  def change
    p = Permission.where(resource: "Issue").first
    UserPermission.where(permission_id: p.id).destroy_all
    p.delete
  end
end
