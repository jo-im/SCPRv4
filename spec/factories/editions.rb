##
# Editions
#
FactoryGirl.define do
  factory :edition do
    status Edition::STATUS_LIVE
    title "Cool Edition"

    trait :published do
      sequence(:published_at) { |n| Time.now + n.hours }
    end

    trait :pending do
      status Edition::STATUS_PENDING
    end

    trait :unpublished do
      status Edition::STATUS_DRAFT
    end
  end

  factory :edition_slot do
    edition
    item { |f| f.association(:abstract) }
    position 0
  end
end
