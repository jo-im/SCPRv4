FactoryGirl.define do
  factory :test_class_alert, class: TestClass::Alert do
    title "Thousands dead; One Wounded."
    email_sent false
    send_email true
  end


  factory :test_class_story, class: TestClass::Story do
    sequence(:headline) { |n| "Cool Headline #{n}" }
    short_headline { "Short #{headline}" }
    body "Cool Body"
    teaser "Cool Teaser"
    slug { headline.parameterize }
    status TestClass::Story.status_id(:live)
    short_url "http://bit.ly/kpcc"

    trait :published do
      status TestClass::Story.status_id(:live)
    end

    trait :pending do
      status TestClass::Story.status_id(:pending)
    end

    trait :unpublished do
      status TestClass::Story.status_id(:draft)
    end
  end

  factory :test_class_remote_story, class: TestClass::RemoteStory do
    headline "Cool Remote Headline"
    short_headline "Cool Remote Short Headline"
    body "Cool Remote Body"
    teaser "Cool Remote Teaser"
    slug { headline.parameterize }
    status TestClass::Story.status_id(:live)
    published_at { Time.zone.now }
    remote_url "http://kpcc.org"
  end

  factory :test_class_post, class: TestClass::Post do
    headline "Cool AssetHeadline"
    short_headline "Cool Asset Short Headline"
    body "Cool Asset Body"
    teaser "Cool Asset Teaser"
    slug { headline.parameterize }
    status TestClass::Story.status_id(:live)
    published_at { Time.zone.now }

    trait :published do
      status TestClass::Story.status_id(:live)
    end

    trait :pending do
      status TestClass::Story.status_id(:pending)
    end
  end

  factory :test_class_post_content, class: TestClass::PostContent do
    test_class_thing_with_asset
  end

  factory :test_class_person, class: TestClass::Person do
    name "Bryan"
    slug { name.parameterize }
  end
end
