##
# Program Audio sync
#
# Created automatically
# when the file appears on the filesystem
# It belongs to a ShowEpisode or ShowSegment
# for a KpccProgram
module AudioSync
  module Program
    extend LogsAsTask
    logs_as_task

    THRESHOLD = 2.weeks

    # 20121001_mbrand.mp3
    FILENAME_REGEX =
      %r{(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<slug>\w+)\.mp3}


    class << self
      include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

      #------------
      # TODO This could be broken up into smaller units
      # Since this is run as a task, we need some informative
      # logging in case of failure, hence the begin/rescue block.
      def bulk_sync
        synced = 0

        # Each KpccProgram with episodes and which can sync audio
        KpccProgram.can_sync_audio.each do |program|
          begin
            audio_path = File.join(Rails.configuration.x.scpr.audio_root, program.audio_dir)

            Timeout::timeout(5) do
              # Each file in this program's audio directory
              Dir.foreach(audio_path).each do |file|
                absolute_mp3_path = File.join(audio_path, file)

                # Move on if:
                # 1. The file is too old -
                #    To keep this process quick, only
                #    worry about files less than 14 days old
                file_date = File.mtime(absolute_mp3_path)
                next if file_date < THRESHOLD.ago

                # 2. The filename doesn't match our regex
                # (won't be able to get date)
                match = file.match(FILENAME_REGEX)
                next if !match

                # Get the date for this episode/segment based on the filename
                # If the date for the audio file can't be discerned, an
                # ArgumentError will be thrown and will be caught by the rescue
                # below.
                date = Time.zone.local(match[:year], match[:month], match[:day])

                # Figure out what type of content we should attach the audio to.
                content = program.episodes.for_air_date(date).includes(:audio).first

                # Compile the URL for this audio
                url = Audio.url(program.audio_dir, file)

                # If there is nothing to attach the audio to, or
                # if the content already has this audio attached to it,
                # then move on.
                next if !content || content.audio.any? { |a| a.url == url }

                # Build the audio
                audio = content.audio.build(
                  :url         => url,
                  :byline      => program.title,
                  :description => content.headline
                )

                # Even though we could, I'd rather not set the
                # file info here. I feel it's better to let the
                # ComputeAudioFileInfo job always handle that.

                # Save the content to touch its timestamp.
                # This will also save the audio and fire its callbacks.
                content.save!
                synced += 1

                self.log  "Saved Audio ##{audio.id} for " \
                          "#{content.simple_title}"
              end # Dir
            end
          rescue => e
            # This needs to rescue StandardError because we don't want a single
            # failed instance to halt the entire process. We know we're dealing
            # with file read errors, ArgumentError (for date parsing at least),
            # NFS errors (although in that case everything should fail),
            # and there's probably other cases we want to catch.
            warn "Error caught in AudioSync::Program.bulk_sync: #{e}"
            self.log "Could not save Audio: #{e}"
            NewRelic.log_error(e)
            next
          end
        end # KpccProgram

        self.log "Finished syncing Audio. Total synced: #{synced}"
      end # bulk_sync

      add_transaction_tracer :bulk_sync, category: :task
    end
  end
end
