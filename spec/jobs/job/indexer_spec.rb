require "spec_helper"

describe Job::Indexer do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:mid_priority] }
end
