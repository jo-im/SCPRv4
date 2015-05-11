require "spec_helper"

describe AudioSync::Program do
  describe "::bulk_sync" do
    let(:program) do
      create :kpcc_program,
        :is_segmented        => true,
        :audio_dir          => "coolshowbro",
        :air_status         => "onair"
    end

    before do
      # October 02, 2012 is the date on the fixture mp3 file
      episode = create :show_episode,
        :air_date   => Time.zone.local(2012, 10, 2),
        :show       => program

      KpccProgram.can_sync_audio.count.should eq 1
    end


    it "doesn't sync if file mtime is too old" do
      Dir.should_receive(:foreach)
      .with(File.join(Rails.configuration.x.scpr.audio_root, program.audio_dir))
      .and_return(["20121002_mbrand.mp3"])

      File.should_receive(:mtime)
      .with(
        File.join(Rails.configuration.x.scpr.audio_root, "coolshowbro/20121002_mbrand.mp3")
      ).and_return(1.month.ago)

      expect { AudioSync::Program.bulk_sync }.not_to change { Audio.count }
    end


    it "doesn't sync if filename doesn't match the regex" do
      Dir.should_receive(:foreach)
      .with(File.join(Rails.configuration.x.scpr.audio_root, program.audio_dir))
      .and_return(["nomatch.mp3"])

      Time.zone.should_not_receive(:new)
      expect { AudioSync::Program.bulk_sync }.not_to change { Audio.count }
    end

    it "doesn't sync if the date can't be parsed" do
      Dir.should_receive(:foreach)
      .with(File.join(Rails.configuration.x.scpr.audio_root, program.audio_dir))
      .and_return(["99999999_mbrand.mp3"])

      # This just checks that the process never gets to the next step.
      expect_any_instance_of(KpccProgram).not_to receive(:display_episodes?)

      expect { AudioSync::Program.bulk_sync }.not_to change { Audio.count }
    end

    context "for episode" do
      before do
        Dir.should_receive(:foreach)
        .with(File.join(Rails.configuration.x.scpr.audio_root, program.audio_dir))
        .and_return(["20121002_mbrand.mp3"])

        File.should_receive(:mtime)
        .with(
          File.join(Rails.configuration.x.scpr.audio_root, "coolshowbro/20121002_mbrand.mp3")
        ).and_return(Time.zone.now) # File new
      end

      it "creates the audio" do
        expect { AudioSync::Program.bulk_sync }.to change { Audio.count }.by(1)
      end

      it "adds the audio to the episode" do
        expect { AudioSync::Program.bulk_sync }
        .to change { program.episodes.first.audio.count }.by(1)
      end

      it "sets the audio description to the episode title" do
        AudioSync::Program.bulk_sync
        episode = program.episodes.first
        episode.audio.first.description.should eq episode.headline
      end

      it "sets the audio byline to the program title" do
        AudioSync::Program.bulk_sync
        program.episodes.first.audio.first.byline.should eq program.title
      end

      it "doesn't sync if the audio already exists for this episode" do
        program.episodes.first.audio.create(
          url: Audio.url("coolshowbro/20121002_mbrand.mp3"))

        expect { AudioSync::Program.bulk_sync }
        .not_to change { Audio.count }
      end
    end
  end
end
