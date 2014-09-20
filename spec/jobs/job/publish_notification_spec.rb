require 'spec_helper'

describe Job::PublishNotification do
  subject { described_class }
  it { subject.queue.should eq "scprv4:low_priority" }

  it "sends the message to campfire" do
    # This is a useless test
    room = double
    campfire = double

    Tinder::Campfire.should_receive(:new).and_return(campfire)
    campfire.should_receive(:find_room_by_id).and_return(room)
    room.should_receive(:speak)

    Job::PublishNotification.perform("cool message", "web_dev")
  end
end
