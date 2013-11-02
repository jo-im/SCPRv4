class AddFeatureTypeToShowSegment < ActiveRecord::Migration
  def change
    add_column :shows_segment, :feature_type, :string
    add_index :shows_segment, :feature_type
  end
end
