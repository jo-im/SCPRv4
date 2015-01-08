require "spec_helper"

describe Job::TwitterCache do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  describe "::perform" do
    pending
  end
end
