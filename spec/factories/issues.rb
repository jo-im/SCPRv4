FactoryGirl.define do
  factory :issue do
    sequence(:title) { |n| "Important Issue #{n}" }

    slug                { title.parameterize }
    description          "This is a very important issue."


    trait :is_active do
      is_active true
    end

    trait :is_not_active do
      is_active false
    end

    factory :active_issue, traits: [:is_active]
    factory :inactive_issue, traits: [:is_not_active]

  end

end
