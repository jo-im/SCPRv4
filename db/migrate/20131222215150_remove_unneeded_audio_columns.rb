class RemoveUnneededAudioColumns < ActiveRecord::Migration
  def up
    remove_column :media_audio, :enco_number
    remove_column :media_audio, :enco_date
    remove_column :media_audio, :mp3
    remove_column :media_audio, :path
  end

  def down
    add_column :media_audio, "enco_number", :string
    add_column :media_audio, "enco_date", :date
    add_column :media_audio, "mp3", :string
    add_column :media_audio, "path", :string
  end
end
