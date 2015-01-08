FactoryGirl.define do
  factory :show_segment do
    sequence(:headline) { |n| "Some Content #{n}" }
    sequence(:short_headline) { |n| "Short #{n}" }

    body    { "Body for #{headline}" }
    teaser  { "Teaser for #{headline}" }

    slug { headline.parameterize }
    show
    published

    after(:create) do |s|
      Job::Indexer.perform s.class.name, s.id, :create
      ContentBase.es_client.indices.refresh index:"_all"
    end

  end

  factory :show_episode do
    sequence(:headline) { |n| "Some Content #{n}" }
    body { "Body for #{headline}" }
    teaser { "Teaser for #{headline}" }

    sequence(:air_date) { |n| Time.zone.now + 60*60*24*n }

    show { |r| r.association(:kpcc_program) }

    status ShowEpisode.status_id(:live)

    trait :published do
      status ShowEpisode.status_id(:live)
    end

    trait :pending do
      status ShowEpisode.status_id(:pending)
    end

    trait :unpublished do
      status ShowEpisode.status_id(:draft)
    end
  end

  factory :show_rundown do
    episode { |r| r.association(:show_episode) }
    segment { |r| r.association(:show_segment) }
  end
end
