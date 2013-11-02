class AddFeatureTypeToBlogEntry < ActiveRecord::Migration
  def change
    add_column :blogs_entry, :feature_type, :string
    add_index :blogs_entry, :feature_type
  end
end
