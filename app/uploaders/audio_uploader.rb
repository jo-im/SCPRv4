# encoding: utf-8

require 'securerandom'

##
# AudioUploader
#
class AudioUploader < CarrierWave::Uploader::Base
  storage :file

  after :store, :update_podcast_episode

  def update_podcast_episode file
    associated_model = self.model
    content_type = associated_model.content_type

    if content_type === "ShowEpisode"
      id = associated_model.content_id
      episode = ShowEpisode.find_by(id: id)
      podcast_episode_record = episode.try(:podcast_episode_record)

      if podcast_episode_record.present?
        podcast_id = podcast_episode_record["podcastId"]
        episode_id = podcast_episode_record["id"]

        backgroundAudioFileUrl = File.join(Rails.configuration.x.scpr.audio_url, relative_dir, filename)

        begin
          $megaphone
            .podcast(podcast_id)
            .episode(episode_id)
            .update({
              backgroundAudioFileUrl: backgroundAudioFileUrl
            })
        rescue
          {}
        end
      end
    end
  end

  #--------------
  # Override default CarrierWave config
  # to move files instead of copy them.
  # Don't do it in test environment so
  # the fixtures stay in place.
  def move_to_cache
    Rails.env != 'test'
  end

  def move_to_store
    Rails.env != 'test'
  end

  #--------------

  def store_dir
    File.join Rails.configuration.x.scpr.audio_root, relative_dir
  end


  # Not part of the Uploader API.
  # This is just so we can share this path between store_dir
  # and URL.
  def relative_dir
    @relative_dir ||= begin
      time = Time.zone.now

      File.join \
        Audio::UPLOAD_DIR,
        time.strftime("%Y"),
        time.strftime("%m"),
        time.strftime("%d")
    end
  end


  def filename
    @random_filename ||= begin
      basename  = File.basename(file.filename, ".*")
      random    = SecureRandom.hex(4)

      "#{basename}-#{random}.#{file.extension}"
    end
  end


  #--------------
  # Only allow mp3's
  # This is checked by Carrierwave, but there is also a validation on the
  # Audio model that will prevent anything except mp3 files from being
  # uploaded, so this white list is just here for safety.
  def extension_white_list
    %w{ mp3 }
  end
end
