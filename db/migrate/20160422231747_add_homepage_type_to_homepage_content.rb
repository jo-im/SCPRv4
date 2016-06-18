class AddHomepageTypeToHomepageContent < ActiveRecord::Migration
  def up
    add_column :layout_homepagecontent, :homepage_type, :string, index: true
    HomepageContent.where(homepage_type: nil).update_all(homepage_type: "Homepage")
  end
  def down
    remove_column :layout_homepagecontent, :homepage_type
  end
end
