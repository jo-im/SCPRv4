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


  describe "sending the e-mail callback" do
    it "queues the job when email should be published" do
      edition = build :edition, :published, send_email: true
      edition.should_send_email?.should eq true

      edition.should_receive(:async_send_email)
      edition.save!
    end

    it "doesn't queue the job if the email shouldn't be sent" do
      edition = build :edition, :published, send_email: false
      edition.should_send_email?.should eq false

      edition.should_not_receive(:async_send_email)
      edition.save!
    end
  end

  describe '#should_send_email?' do
    it "is true if published, we want to send, and the e-mail hasn't been sent" do
      edition = build :edition, :published, send_email: true, email_sent: false
      edition.should_send_email?.should eq true
    end

    it "is false if the email has already been sent" do
      edition = build :edition, :published, send_email: true, email_sent: true
      edition.should_send_email?.should eq false
    end

    it "is false if an e-mail isn't requested" do
      edition = build :edition, :published, send_email: false
      edition.should_send_email?.should eq false
    end

    it "is false if unpublished" do
      edition = build :edition, :unpublished, send_email: true
      edition.should_send_email?.should eq false
    end
  end

  describe "email bodies" do
    let(:edition) { build :edition }

    before do
      abstract1 = build :abstract
      abstract2 = build :abstract

      edition.slots.build(item: abstract1)
      edition.slots.build(item: abstract2)

      edition.save!
    end

    describe '#email_html_body' do
      it 'is a string containing some html' do
        edition.email_html_body.should match /<html/
      end
    end

    describe '#email_plain_text_body' do
      it 'is a string containing some text' do
        edition.email_plain_text_body.should match edition.title
      end
    end
  end


  describe '#email_name' do
    it 'is a string with part of the title in it' do
      edition = build :edition, title: "some important news that goes pretty long"
      edition.email_name.should match edition.title[0..30]
    end
  end

  describe '#email_description' do
    it 'has the subject and some descriptive stuff and junk' do
      edition = build :edition, title: "Hundreds Die in Fire; Grep Proops Unharmed"
      abstract = build :abstract
      edition.slots.build(item: abstract)
      edition.save!

      edition.email_description.should match edition.title
    end
  end

  describe '#email_subject' do
    it 'has the edition title and abstract headline' do
      edition = build :edition, title: "Hundreds Die in Fire; Grep Proops Unharmed"
      abstract = build :abstract
      edition.slots.build(item: abstract)
      edition.save!

      edition.email_subject.should match edition.title
      edition.email_subject.should match abstract.headline
    end
  end
end
