module Job
  class UpdateMegaphoneAudio < Base
    @priority = :mid

    class << self
      def perform options={}
        begin
          $megaphone
            .podcast(options[:podcast_id])
            .episode(options[:episode_id])
            .update({
              backgroundAudioFileUrl: options[:background_audio_file_url]
            })
        rescue
          {}
        end
      end
    end
  end
end
