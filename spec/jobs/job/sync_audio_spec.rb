require "spec_helper"

describe Job::SyncAudio do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  describe "::perform" do
    it "sends to module.bulk_sync" do
      AudioSync::Pending.should_receive(:bulk_sync)
      AudioSync::Program.should_receive(:bulk_sync)
      Job::SyncAudio.perform("AudioSync::Pending", "AudioSync::Program")
    end
  end
end
