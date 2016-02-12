##
# Categories
#
FactoryGirl.define do
  factory :pledge_drive do
    trait :happened do
      starts_at 3.days.ago
      ends_at 1.day.ago
    end
    trait :happening do
      starts_at 1.day.ago
      ends_at Time.zone.now + 1.day
    end
    trait :will_happen do
      starts_at Time.zone.now + 1.day
      ends_at Time.zone.now + 2.days
    end
    trait :enabled do
      enabled true
    end
  end
end