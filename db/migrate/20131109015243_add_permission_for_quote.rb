class AddPermissionForQuote < ActiveRecord::Migration
  def up
    Permission.create(resource: "Quote")
  end

  def down
    Permission.destroy_all resource: "Quote"
  end
end
