##
# Content Emails
#
FactoryGirl.define do
  factory :content_email do # Must pass in content
    from_email  "bricker@kpcc.org"
    to_email    "bricker@scpr.org"
  end
end
