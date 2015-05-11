require "spec_helper"

describe Job::DelayedMailer do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  describe "::perform" do
    it "delivers the e-mail" do
      content = create :blog_entry
      msg = build :content_email

      ActionMailer::Base.deliveries.size.should eq 0

      Job::DelayedMailer.perform("ContentMailer", :email_content,
        [msg.to_json, content.obj_key])

      ActionMailer::Base.deliveries.size.should eq 1
    end
  end
end
