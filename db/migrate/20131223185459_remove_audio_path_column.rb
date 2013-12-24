class RemoveAudioPathColumn < ActiveRecord::Migration
  def up
    remove_column :media_audio, :path
  end

  def down
    add_column :media_audio, "path", :string
  end
end
