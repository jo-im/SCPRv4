require 'spec_helper'

describe Job::SendEmailNotification do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:mid_priority] }

  before :each do
    stub_request(:post, %r|assets/email|).to_return({
      :content_type   => "application/json",
      :body           => load_fixture("api/eloqua/email.json")
    })

    stub_request(:post, %r|assets/campaign/active|).to_return({
      :content_type   => "application/json",
      :body           => load_fixture("api/eloqua/campaign_activated.json")
    })

    stub_request(:post, %r|assets/campaign\z|).to_return({
      :content_type   => "application/json",
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

  # context "with edition" do
  #   describe '::perform' do
  #     context "shortlist email" do
  #       it 'sends the email' do
  #         story = create :news_story
  #         edition = create :edition, :published
  #         slot = create :edition_slot, edition: edition, item: story
  #         edition.shortlist_email_sent?.should eq false

  #         Job::SendEmailNotification.perform("Edition", edition.id)
  #         edition.reload.shortlist_email_sent?.should eq true
  #       end

  #       it "sends the e-mail if any of the abstracts doesn't have a category" do
  #         edition = create :edition, :published
  #         abstract1 = create :abstract, category: nil
  #         abstract2 = create :abstract, category: nil

  #         create :edition_slot, edition: edition, item: abstract1
  #         create :edition_slot, edition: edition, item: abstract2
  #         edition.shortlist_email_sent?.should eq false

  #         Job::SendEmailNotification.perform("Edition", edition.id)
  #         edition.reload.shortlist_email_sent?.should eq true
  #       end
  #     end
  #   end
  # end
end
