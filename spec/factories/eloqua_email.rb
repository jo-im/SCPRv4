FactoryGirl.define do
  factory :eloqua_email do
    html_template "/editions/email/template"
    plain_text_template "/editions/email/template"
    name "test name"
    description "test description"
    subject "test subject"
    email "theshortlist@scpr.org"
    email_type "edition"
    email_sent false
    # emailable Edition.new
  end
end
