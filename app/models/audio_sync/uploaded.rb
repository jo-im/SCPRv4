##
# UploadedAudio
#
# Uploaded via the CMS
# Doesn't need to be synced
#
module AudioSync
  class Uploaded < Base
    # Find the URL for the given information.
    #
    # Returns String
    def set_url
      uploder = AudioUploader.new(audio)
      uploader.store!(audio.mp3)

      audio.url = uploader.url
    end
  end
end
