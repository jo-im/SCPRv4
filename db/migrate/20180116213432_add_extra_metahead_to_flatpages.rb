class AddExtraMetaheadToFlatpages < ActiveRecord::Migration
  def up
    add_column :flatpages_flatpage, :extra_metahead, :text
  
  def down
    remove_column :flatpages_flatpage, :extra_metahead, :text
  end
end

