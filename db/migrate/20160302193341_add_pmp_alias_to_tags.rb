class AddPmpAliasToTags < ActiveRecord::Migration
  def change
    add_column :tags, :pmp_alias, :string
  end
end
