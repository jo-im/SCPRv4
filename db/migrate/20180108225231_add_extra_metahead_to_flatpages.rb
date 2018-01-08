class AddExtraMetaheadToFlatpages < ActiveRecord::Migration
  def change
    if !column_exists?(:flatpages_flatpage, :extra_metahead)
      add_column :flatpages_flatpage, :extra_metahead, :string
    end
  end
end
