##
# Categories
#
FactoryGirl.define do
  factory :category do
    sequence(:title) { |n| "Local #{n}" }

    trait :is_news do
      is_news true
    end

    trait :is_not_news do
      is_news false
    end

    slug { title.parameterize }

    factory :category_news, traits: [:is_news]
    factory :category_not_news, traits: [:is_not_news]

  end
   factory :category_article do
     category
     article {|f| f.association(:news_story) }
     position 0
   end

end
