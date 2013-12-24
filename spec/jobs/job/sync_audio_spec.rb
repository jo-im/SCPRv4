require "spec_helper"

describe Job::SyncAudio do
  describe "::perform" do
    it "sends to module.bulk_sync" do
      AudioSync::Pending.should_receive(:bulk_sync)
      AudioSync::Program.should_receive(:bulk_sync)
      Job::SyncAudio.perform("AudioSync::Pending", "AudioSync::Program")
    end
  end
end
