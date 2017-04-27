require 'spec_helper'

describe Job::SendEmailNotification do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:mid_priority] }

  before :each do
    stub_request(:post, %r|assets/email|).to_return({
      :headers => {
        :content_type   => "application/json"
      },
      :body           => load_fixture("api/eloqua/email.json")
    })

    stub_request(:post, %r|assets/campaign/active|).to_return({
      :headers => {
        :content_type   => "application/json"
      },
      :body           => load_fixture("api/eloqua/campaign_activated.json")
    })

    stub_request(:post, %r|assets/campaign\z|).to_return({
      :headers => {
        :content_type   => "application/json"
      },
      :body           => load_fixture("api/eloqua/email.json")
    })
  end

  context "with breaking news alert" do
    describe '::perform' do
      it 'sends the email' do
        alert = create :breaking_news_alert, :email, :published
        alert.email_sent?.should eq false

        Job::SendEmailNotification.perform("BreakingNewsAlert", alert.id)
        alert.reload.email_sent?.should eq true
      end
    end
  end
end
