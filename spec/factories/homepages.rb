##
# Homepages
#
FactoryGirl.define do
  factory :homepage do
    base "default"
    sequence(:published_at) { |n| Time.now + 60*60*n }
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

  factory :homepage_content do
    homepage
    content { |hc| hc.association(:content_shell) }
  end
end
