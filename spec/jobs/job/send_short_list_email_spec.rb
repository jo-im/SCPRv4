require 'spec_helper'

describe Job::SendShortListEmail do
  before :each do
    stub_request(:post, %r|assets/email|).to_return({
      :content_type   => "application/json",
      :body           => load_fixture("api/eloqua/email.json")
    })

    stub_request(:post, %r|assets/campaign\z|).to_return({
      :content_type   => "application/json",
      :body           => load_fixture("api/eloqua/email.json")
    })
  end

  describe '::perform' do
    it 'sends the email' do
      story = create :news_story
      edition = create :edition, :published
      slot = create :edition_slot, edition: edition, item: story
      edition.email_sent?.should eq false

      Job::SendShortListEmail.perform(edition.id)
      edition.reload.email_sent?.should eq true
    end

    it "sends the e-mail if any of the abstracts doesn't have a category" do
      edition = create :edition, :published
      abstract1 = create :abstract, category: nil
      abstract2 = create :abstract, category: nil

      create :edition_slot, edition: edition, item: abstract1
      create :edition_slot, edition: edition, item: abstract2
      edition.email_sent?.should be_false

      Job::SendShortListEmail.perform(edition.id)
      edition.reload.email_sent?.should be_true
    end
  end
end

