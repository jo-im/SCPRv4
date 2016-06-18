##
# Homepages
#
FactoryGirl.define do
  factory :better_homepage do
    sequence(:published_at) { |n| Time.zone.now + 60*60*n }
    status Homepage.status_id(:live)

    trait :pending do
      status Homepage.status_id(:pending)
    end

    trait :published do
      status Homepage.status_id(:live)
      published_at { 2.hours.ago }
    end
  end

  #-----------------------

  factory :better_homepage_content do
    better_homepage
    content { |hc| hc.association(:content_shell) }
  end
end
