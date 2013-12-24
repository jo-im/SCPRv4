##
# ProgramAudio
#
# Created automatically
# when the file appears on the filesystem
# It belongs to a ShowEpisode or ShowSegment
# for a KpccProgram
#
# Doesn't need an instance `#sync` method,
# because an instance is only created if
# the audio exists.
#
module AudioSync
  module Program
    extend LogsAsTask
    logs_as_task

    THESHOLD = 2.weeks

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
        # Each KpccProgram with episodes and which can sync audio
        KpccProgram.can_sync_audio.each do |program|
          begin
            audio_path = File.join(Audio::AUDIO_PATH_ROOT, program.audio_dir)

            # Each file in this program's audio directory
            Dir.foreach(audio_path).each do |file|
              absolute_mp3_path = File.join(audio_path, file)

              # Move on if:
              # 1. The file is too old -
              #    To keep this process quick, only
              #    worry about files less than 14 days old
              file_date = File.mtime(absolute_mp3_path)
              next if file_date < THESHOLD.ago

              # 2. File already exists (program audio only needs to
              # exist once in the DB)
              next if existing[File.join(program.audio_dir, file)]

              # 3. The filename doesn't match our regex
              # (won't be able to get date)
              match = file.match(FILENAME_REGEX)
              next if !match

              # Get the date for this episode/segment based on the filename,
              # find that episode/segment, and create the audio / association
              # if the content for that date exists.
              date = Time.new(match[:year], match[:month], match[:day])

              # Figure out what type of content we should attach the audio to.
              if program.display_episodes?
                content = program.episodes.for_air_date(date)
              else
                content = program.segments.where(
                  published_at: date..date.end_of_day)
              end

              content = content.includes(:audio).first

              # Compile the URL for this audio
              url = Audio.url(program.audio_dir, file.filename)

              # If there is nothing to attach the audio too, or
              # if the content already has this audio attached to it,
              # then move on.
              next if !content || content.audio.any? { |a| a.url == url }

              # Build the audio
              audio = Audio.new(
                :content     => content,
                :url         => url,
                :description => content.headline
              )

              # Even though we could, I'd rather not set the
              # file info here. I feel it's better to let the
              # ComputeAudioFileInfo job always handle that.

              # Saving will trigger the file info job.
              synced << audio if audio.save!

              self.log  "Saved ProgramAudio ##{audio.id} for " \
                        "#{content.simple_title}"
            end # Dir

          rescue => e
            self.log "Could not save ProgramAudio: #{e}"
            NewRelic.log_error(e)
            next
          end
        end # KpccProgram

        self.log "Finished syncing ProgramAudio. Total synced: #{synced.size}"
        synced
      end # bulk_sync

      add_transaction_tracer :bulk_sync, category: :task

      #------------

      private

      #------------------------
      # An array of what got synced
      def synced
        @synced ||= []
      end
    end
  end
end
