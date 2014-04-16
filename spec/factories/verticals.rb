FactoryGirl.define do
  factory :vertical do
    sequence(:title) { |n| "Local #{n}" }
    slug { title.parameterize }
  end

  factory :vertical_article do
    vertical
    article { |f| f.association(:news_story) }
    position 0
  end

  factory :vertical_issue do
    vertical
    issue
  end

  factory :vertical_reporter do
    vertical
    bio
  end
end
