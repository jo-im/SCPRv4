class RenameAudioUrlColumn < ActiveRecord::Migration
  def change
    rename_column :media_audio, :external_url, :url
  end
end
