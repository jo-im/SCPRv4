class PolymorphicShowRundonw < ActiveRecord::Migration
  def change
    add_column :shows_rundown, :content_type, :string
    ShowRundown.update_all(content_type: "ShowSegment")
    remove_index :shows_rundown, name: "shows_rundown_segment_id"

    rename_column :shows_rundown, :segment_id, :content_id
    add_index :shows_rundown, [:content_type, :content_id]
  end
end
