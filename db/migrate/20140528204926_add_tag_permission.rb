class AddTagPermission < ActiveRecord::Migration
  def change
    Permission.create(resource: "Tag")
  end
end
