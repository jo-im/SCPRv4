FactoryGirl.define do
  factory :tag do
    sequence(:title) { |n| "Tag #{n}" }
    slug { title.parameterize }
  end
end
