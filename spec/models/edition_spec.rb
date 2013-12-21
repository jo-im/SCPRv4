require 'spec_helper'

describe Edition do
  describe '::titles_collection' do
    it "is an array of all the published titles" do
      create :edition, :published, title: "Abracadabra"
      create :edition, :unpublished, title: "Marmalade"
      create :edition, :published, title: "Zealot"

      Edition.titles_collection.should eq ["Abracadabra", "Zealot"]
    end
  end

  describe '#title' do
    it "validates title when the edition is pending" do
      edition = build :edition, :pending, title: nil
      edition.should_not be_valid
      edition.errors.keys.should eq [:title]
    end

    it "validates title when the edition is published" do
      edition = build :edition, :published, title: nil
      edition.should_not be_valid
      edition.errors.keys.should eq [:title]
    end

    it "doesn't validate title when the edition is draft" do
      edition = build :edition, :unpublished, title: nil
      edition.should be_valid
    end
  end

  describe '#abstracts' do
    it 'turns all of the items into abstracts' do
      edition   = create :edition, :published
      story     = create :news_story
      slot      = create :edition_slot, edition: edition, item: story

      edition.abstracts.map(&:class).uniq.should eq [Abstract]
    end
  end

  describe '#articles' do
    it 'turns all of the items into articles' do
      edition   = create :edition, :published
      story     = create :news_story
      slot      = create :edition_slot, edition: edition, item: story

      edition.articles.map(&:class).uniq.should eq [Article]
    end
  end

  describe '#publish' do
    it 'sets the status to published' do
      edition = create :edition, :pending
      edition.published?.should eq false
      edition.publish

      edition.reload.published?.should eq true
    end
  end

  describe "#publish_email" do
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

    it 'sends the e-mail and sets email_sent? to true' do
      story = create :news_story
      edition = create :edition, :email, :published
      slot = create :edition_slot, edition: edition, item: story

      edition.email_sent?.should eq false

      edition.publish_email
      edition.reload.email_sent?.should eq true
    end

    it 'returns false and does not send the email if not published' do
      story = create :news_story
      edition = create :edition, :email, :draft
      slot = create :edition_slot, edition: edition, item: story

      edition.publish_email.should eq false
      edition.reload.email_sent?.should eq false
    end

    it 'returns false and does not send the email if not emailized' do
      story = create :news_story
      edition = create :edition, :published
      slot = create :edition_slot, edition: edition, item: story

      edition.publish_email.should eq false
      edition.reload.email_sent?.should eq false
    end
  end

  describe '#async_send_email' do
    it 'enqueues the job' do
      edition = create :edition

      Resque.should_receive(:enqueue).with(
        Job::SendShortListEmail, edition.id)

      edition.async_send_email
    end
  end
end
