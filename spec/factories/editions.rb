##
# Editions
#
FactoryGirl.define do
  factory :edition do
    status Edition.status_id(:live)
    sequence(:title) { |n| "Cool Edition #{n}" }
    slug "am-edition"
    shortlist_email_sent false
    monday_shortlist_email_sent false
    
    trait :published do
      sequence(:published_at) { |n| Time.zone.now + n.hours }
    end

    trait :pending do
      status Edition.status_id(:pending)
    end

    trait :unpublished do
      status Edition.status_id(:draft)
    end

    trait :with_abstract do
      slots { |f| [f.association(:edition_slot)] }
    end
  end

  factory :edition_slot do
    edition
    item { |f| f.association(:abstract) }
    position 0
  end
end
