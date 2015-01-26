require 'spec_helper'

describe Job::PublishNotification do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }
end
