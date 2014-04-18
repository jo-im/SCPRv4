##
# Categories
#
FactoryGirl.define do
  factory :category do
    sequence(:title) { |n| "Local #{n}" }

    is_news true

    trait :is_news do
    end

    trait :is_not_news do
      is_news false
    end

    slug { title.parameterize }

    factory :category_news, traits: [:is_news]
    factory :category_not_news, traits: [:is_not_news]
  end
end
