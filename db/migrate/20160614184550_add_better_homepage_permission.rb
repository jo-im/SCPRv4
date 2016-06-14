class AddBetterHomepagePermission < ActiveRecord::Migration
  def up
    Permission.where(resource: "BetterHomepage").first_or_create
  end
  def down
    Permission.where(resource: "BetterHomepage").destroy_all
  end
end
