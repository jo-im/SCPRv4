class AddExternalAssetToContentAssets < ActiveRecord::Migration
  def change
    add_column :assethost_contentasset, :external_asset, :text
  end
end
