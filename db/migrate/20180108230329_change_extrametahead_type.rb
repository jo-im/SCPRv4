class ChangeExtrametaheadType < ActiveRecord::Migration
  def up
   change_column :flatpages_flatpage, :extra_metahead, :text
  end

  def down
   change_column :flatpages_flatpage, :extra_metahead, :string
  end
end
