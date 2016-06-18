class RenameHomepageAssetDisplayToScheme < ActiveRecord::Migration
  def change
    rename_column :layout_homepagecontent, :asset_display, :asset_scheme
  end
end
