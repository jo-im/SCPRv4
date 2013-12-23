class MoveAudioInfoIntoUrlColumn < ActiveRecord::Migration
  def up
    Audio.where(url: nil).find_each do |audio|
      if audio.path.present?
        url = Audio.url(audio.path)
        audio.update_column(:url, url)
      end
    end
  end

  def down
    # meh
  end
end
