module TestClass
  class Alert < ActiveRecord::Base
    self.table_name = "test_class_alerts"

    include Concern::Methods::EloquaSendable

    def as_eloqua_email
      subject = "Alert: #{self.title}"
      {
        :html_body       => "Cool Body",
        :plain_text_body => "Cool Plaintext",
        :name            => "#{self.title[0..30]}",
        :description     => "SCPR Alert\n" \
                            "Sent: #{Time.now}\nSubject: #{subject}",
        :subject         => subject
      }
    end


    private

    def should_send_email?
      self.send_email? &&
      !self.email_sent?
    end

    def update_email_status(campaign)
      self.update_column(:email_sent, true)
    end
  end
end
