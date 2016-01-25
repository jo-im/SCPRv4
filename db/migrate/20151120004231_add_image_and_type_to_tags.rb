class AddImageAndTypeToTags < ActiveRecord::Migration
  def change
    add_column :tags, :image, :string
    add_column :tags, :tag_type, :string, default: "Keyword", index: true
  end
end
