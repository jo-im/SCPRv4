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
        # eloqua_email = build :eloqua_email, html_template: "/editions/email/template"
        eloqua_email.html_body.should match /<html/
      end
    end

  end
end
