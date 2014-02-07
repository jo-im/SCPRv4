class MoveAudioInfoIntoUrlColumn < ActiveRecord::Migration
  def up
    Audio.where("external_url is null or external_url = ?", "").find_each do |audio|
      if audio.path.present?
        url = "http://media.scpr.org/audio/#{audio.path}"
        audio.update_column(:external_url, url)
      end
    end
  end

  def down
    # meh
  end
end
