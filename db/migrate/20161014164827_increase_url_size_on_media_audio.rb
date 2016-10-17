class IncreaseUrlSizeOnMediaAudio < ActiveRecord::Migration
  def up
    change_column :media_audio, :url, :string, limit: 512
  end
  def down
    change_column :media_audio, :url, :string, limit: 512
  end
end
