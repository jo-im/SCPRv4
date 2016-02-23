class MakeShowRundownsPolymorphic < ActiveRecord::Migration
  def up
    add_column :shows_rundown, :content_type, :string
    rename_column :shows_rundown, :segment_id, :content_id
    ShowRundown.update_all(content_type: "ShowSegment")
  end
  def down
    ShowRundown.where.not(content_type: "ShowSegment").destroy_all
    remove_column :shows_rundown, :content_type
    rename_column :shows_rundown, :content_id, :segment_id
  end
end