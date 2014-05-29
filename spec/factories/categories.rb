##
# Categories
#
FactoryGirl.define do
  factory :category do
    sequence(:title) { |n| "Local #{n}" }

    slug { title.parameterize }
  end
end
