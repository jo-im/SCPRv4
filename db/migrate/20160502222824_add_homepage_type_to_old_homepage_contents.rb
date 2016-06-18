class AddHomepageTypeToOldHomepageContents < ActiveRecord::Migration
  def up
    HomepageContent.where(homepage_type: nil).update_all(homepage_type: "Homepage")
  end
  def down
  end
end
