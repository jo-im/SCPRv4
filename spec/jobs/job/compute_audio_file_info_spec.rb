require "spec_helper"

describe Job::ComputeAudioFileInfo do
  describe "::perform" do
    it "finds the audio and finds the duration and size, and saves" do
      audio = create :audio, :direct

      audio.size.should eq nil
      audio.duration.should eq nil

      Job::ComputeAudioFileInfo.perform(audio.id)
      audio.reload

      audio.size.should be > 0
      audio.duration.should eq 2 # 2sec file
    end

    it "doesn't try to compute duration if it's already available" do
      audio = create :audio, :direct, duration: 999

      Audio.any_instance.should_not_receive(:compute_duration)
      Job::ComputeAudioFileInfo.perform(audio.id)
    end

    it "doesn't try to compute size if it's already available" do
      audio = create :audio, :direct, size: 999

      Audio.any_instance.should_not_receive(:compute_size)
      Job::ComputeAudioFileInfo.perform(audio.id)
    end

    it "doesn't compute info if the file is blank" do
      audio = create :audio, :direct
      Audio.any_instance.should_receive(:file) # nil

      Job::ComputeAudioFileInfo.perform(audio.id)

      audio.reload
      audio.duration.should be_nil
      audio.size.should be_nil
    end
  end
end
