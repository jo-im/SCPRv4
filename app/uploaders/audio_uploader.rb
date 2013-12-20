# encoding: utf-8

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
    Rails.env == 'test' ? false : true
  end

  def move_to_store
    Rails.env == 'test' ? false : true
  end

  #--------------

  def store_dir
    time = model.created_at || Time.now

    File.join \
      Rails.application.config.scpr.media_root,
      "audio",
      time.strftime("%Y"),
      time.strftime("%m"),
      time.strftime("%d")
  end

  #--------------
  # Only allow mp3's
  def extension_white_list
    %w{ mp3 }
  end
end
