class RemoveAudioTypeColumn < ActiveRecord::Migration
  def up
    remove_column :media_audio, :type
  end

  def down
    add_column :media_audio, "type", :string
  end
end
