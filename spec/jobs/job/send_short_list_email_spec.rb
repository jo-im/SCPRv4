require 'spec_helper'

describe Job::SendShortListEmail do
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

  describe '::perform' do
    it 'sends the email' do
      story = create :news_story
      edition = create :edition, :email, :published
      slot = create :edition_slot, edition: edition, item: story
      edition.email_sent?.should eq false

      Job::SendShortListEmail.perform(edition.id)
      edition.reload.email_sent?.should eq true
    end
  end
end

