class AddAssetSchemeColumnToHomepageContentTable < ActiveRecord::Migration
  def change
    add_column :layout_homepagecontent, :asset_display, :string
  end
end
