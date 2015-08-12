require 'spec_helper'

describe EloquaEmail do
  describe '#as_eloqua_email' do
    let(:eloqua_email) {
      build :eloqua_email
    }

    describe "job queue" do
      it "queues the job when email should be published" do
        eloqua_email.should_receive(:async_send_email)
        eloqua_email.save!
      end

      it "doesn't queue the job if the email was already sent" do
        eloqua_email = build :eloqua_email, email_sent: true
        eloqua_email.should_not_receive(:async_send_email)
        eloqua_email.save!
      end
    end

    describe "templates" do
      it "renders an html body" do
        edition = build :edition, :with_abstract
        edition.save
        eloqua_email = edition.eloqua_emails.last
        eloqua_email.html_body.should match /<html/
      end

      it "renders an plain text body" do
        edition = build :edition, :with_abstract
        edition.save
        eloqua_email = edition.eloqua_emails.last
        eloqua_email.plain_text_body.should be_a String
      end
    end

    describe "#publish_email" do
      before do
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

        # Just incase, we don't want this method queueing anything
        # since we're testing the publish method directly.
        Edition.any_instance.stub(:async_send_email)
      end
      it "sets email_sent to true" do
        edition = build :edition, :with_abstract
        edition.save
        eloqua_email = edition.eloqua_emails.last
        eloqua_email.publish_email
        eloqua_email.email_sent.should be true
      end
    end

  end
end
