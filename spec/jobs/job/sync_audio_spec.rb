require "spec_helper"

describe Job::SyncAudio do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  describe "::perform" do
    it "sends to klass.bulk_sync" do
      Audio.should_receive(:bulk_sync)
      Job::SyncAudio.perform("Audio")
    end
  end
end
