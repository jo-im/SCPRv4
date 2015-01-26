require "spec_helper"

describe Concern::Callbacks::PublishNotificationCallback do
  it "fires when publishing" do
    story = build :test_class_story, :published
    Job::PublishNotification.should_receive(:enqueue).with(/\APublished!/, story.obj_key)
    story.save!
  end

  it "fires when unpublishing" do
    story = create :test_class_story, :published

    Job::PublishNotification.should_receive(:enqueue).with(/\AUnpublished/, story.obj_key)

    story.status = story.class.status_id(:pending)
    story.save!
  end

  it "fires when status was changed" do
    story = create :test_class_story, :draft
    Job::PublishNotification.should_receive(:enqueue).with(/\AStatus Changed/, story.obj_key)

    story.status = story.class.status_id(:pending)
    story.save!
  end

end
