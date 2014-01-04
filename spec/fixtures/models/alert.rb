module TestClass
  class Alert < ActiveRecord::Base
    self.table_name = "test_class_alerts"

    include Concern::Methods::EloquaSendable

    def email_html_body
      "Cool Body"
    end

    def email_plain_text_body
      "Cool Plaintext"
    end

    def email_name
      @email_name ||= "#{self.title[0..30]}"
    end

    def email_description
      @email_description ||= "SCPR Alert\n" \
        "Sent: #{Time.now}\nSubject: #{email_subject}"
    end

    def email_subject
      @email_subject ||= "Alert: #{self.title}"
    end



    private

    def should_send_email?
      self.send_email? &&
      !self.email_sent?
    end
  end
end
