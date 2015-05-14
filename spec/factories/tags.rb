FactoryGirl.define do
  factory :tag do
    sequence(:title) { |n| "Tag #{n}" }
    slug { title.parameterize }
    description { "A tag description"}
  end

  factory :tagging do
    tag
    taggable { |f| f.association :news_story }
  end
end
