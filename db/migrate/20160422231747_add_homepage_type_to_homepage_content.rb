class AddHomepageTypeToHomepageContent < ActiveRecord::Migration
  def change
    add_column :layout_homepagecontent, :homepage_type, :string, index: true
  end
end
