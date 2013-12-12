##
# PIJ Queries
#
FactoryGirl.define do
  factory :pij_query do
    sequence(:headline) { |n| "PIJ Query ##{n}"}
    teaser "This a teaser"
    body { "Body: #{teaser}" }
    slug { headline.parameterize }
    query_type "news"
    pin_query_id '01aa97973688'
    status PijQuery.status_id(:live)

    trait :featured do
      is_featured true
    end

    trait :published do
      status PijQuery.status_id(:live)
    end

    trait :pending do
      status PijQuery.status_id(:pending)
    end
  end
end
