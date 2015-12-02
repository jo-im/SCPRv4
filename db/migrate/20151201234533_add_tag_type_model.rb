class AddTagTypeModel < ActiveRecord::Migration
  def up
    create_table :tag_types do |t|
      t.string :name
      t.timestamps null: false
    end
    add_column :tags, :tag_type_id, :integer, default: 1, index: true
    remove_column :tags, :tag_type
    ["Keyword", "Series", "Beat"].each do |tag_type_name|
      TagType.create name: tag_type_name
    end
    Permission.create resource: "TagType"
  end
  def down
    Permission.where(resource: "TagType").delete_all
    drop_table :tag_types
    remove_column :tags, :tag_type_id
    add_column :tags, :tag_type, :string, default: "Keyword", index: true
  end
end
