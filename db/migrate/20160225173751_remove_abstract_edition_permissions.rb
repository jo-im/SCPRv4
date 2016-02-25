class RemoveAbstractEditionPermissions < ActiveRecord::Migration
  def up
    if (ids = Permission.where(resource: ["Edition", "Abstract"]).pluck(:id)).any?
      UserPermission.where(permission_id: ids).destroy_all
    end
  end
  def down
  end
end
