class AddLandingPagePermission < ActiveRecord::Migration
  def up
    Permission.create(resource: 'LandingPage')
  end

  def down
    Permission.where(resource: 'LandingPage').destroy_all
  end
end
