class AddAssetSchemeColumnToHomepageContentTable < ActiveRecord::Migration
  def change
    add_column :layout_homepagecontent, :asset_scheme, :string
  end
end
