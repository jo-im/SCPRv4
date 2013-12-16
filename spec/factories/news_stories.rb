FactoryGirl.define do
  factory :news_story do
    sequence(:headline) { |n| "Long Headline #{n}!!" }
    sequence(:short_headline) { |n| "Short #{n}!" }

    body    { "Body for #{headline}" }
    teaser  { "Teaser for #{headline}" }

    slug { headline.parameterize }

    published
  end
end
