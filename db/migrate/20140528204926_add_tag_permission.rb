class AddTagPermission < ActiveRecord::Migration
  def change
    tp = Permission.create(resource: "Tag")

    ip = Permission.where(resource: "Issue").first

    UserPermission.where(permission_id: ip.id).each do |up|
      UserPermission.create(user_id: up.id, permission_id: tp.id)
    end
  end
end
