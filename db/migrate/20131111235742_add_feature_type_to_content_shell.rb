class AddFeatureTypeToContentShell < ActiveRecord::Migration
  def change
    add_column :contentbase_contentshell, :feature_type, :integer
    add_index :contentbase_contentshell, :feature_type
  end
end
