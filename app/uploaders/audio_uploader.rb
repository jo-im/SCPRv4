# encoding: utf-8

require 'securerandom'

##
# AudioUploader
#
class AudioUploader < CarrierWave::Uploader::Base
  storage :file

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
    File.join Audio::AUDIO_PATH_ROOT, relative_dir
  end


  # Not part of the Uploader API.
  # This is just so we can share this path between store_dir
  # and URL.
  def relative_dir
    @relative_dir ||= begin
      time = Time.now

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
  def extension_white_list
    %w{ mp3 }
  end
end
