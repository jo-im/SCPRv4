class AddExtraMetaheadToFlatpages < ActiveRecord::Migration
  def up
    add_column :flatpages_flatpage, :extra_metahead, :text, :limit => 4294967295
  end
  
  def down
    remove_column :flatpages_flatpage, :extra_metahead, :text
  end
end
