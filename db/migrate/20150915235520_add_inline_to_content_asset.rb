class AddInlineToContentAsset < ActiveRecord::Migration
  def change
    add_column :assethost_contentasset, :inline, :boolean, default: false, index: true
  end
end
