FactoryGirl.define do
  factory :news_story do
    sequence(:headline) { |n| "Long Headline #{n}!!" }
    sequence(:short_headline) { |n| "Short #{n}!" }

    body    { "Body for #{headline}" }
    teaser  { "Teaser for #{headline}" }

    slug { headline.parameterize }

    category_id 1

    published

    after(:create) do |s|
      Job::Indexer.perform s.class.name, s.id, :create
      ContentBase.es_client.indices.refresh index:"_all"
    end
  end
end
