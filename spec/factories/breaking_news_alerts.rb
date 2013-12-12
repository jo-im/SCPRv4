##
# Breaking News Alerts
#
FactoryGirl.define do
  factory :breaking_news_alert do
    headline      "Breaking news!"
    teaser        "This is breaking news"
    alert_type    "break"
    alert_url    "http://scpr.org/"
    visible       true
    status BreakingNewsAlert.status_id(:published)

    send_email    false
    email_sent    false

    send_mobile_notification false
    mobile_notification_sent false

    trait :published do
      status BreakingNewsAlert.status_id(:published)
      sequence(:published_at) { |n| Time.now + n.minutes }
    end

    trait :pending do
      status BreakingNewsAlert.status_id(:pending)
    end

    trait :email do
      send_email true
    end

    trait :mobile do
      send_mobile_notification true
    end
  end
end
