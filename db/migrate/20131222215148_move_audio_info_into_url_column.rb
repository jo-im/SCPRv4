class MoveAudioInfoIntoUrlColumn < ActiveRecord::Migration
  def up
    Audio.where("url is null or url = ?", "").find_each do |audio|
      if audio.path.present?
        url = "http://media.scpr.org/audio/#{audio.path}"
        audio.update_column(:url, url)
      end
    end
  end

  def down
    # meh
  end
end
