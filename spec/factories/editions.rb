##
# Editions
#
FactoryGirl.define do
  factory :edition do
    status Edition.status_id(:live)
    sequence(:title) { |n| "Cool Edition #{n}" }

    send_email false
    email_sent false

    trait :published do
      sequence(:published_at) { |n| Time.now + n.hours }
    end

    trait :pending do
      status Edition.status_id(:pending)
    end

    trait :unpublished do
      status Edition.status_id(:draft)
    end
  end

  trait :email do
    send_email true
  end

  factory :edition_slot do
    edition
    item { |f| f.association(:abstract) }
    position 0
  end
end
