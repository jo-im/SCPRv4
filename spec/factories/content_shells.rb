FactoryGirl.define do
  factory :content_shell do
    sequence(:headline)   { |n| "Some Content #{n}" }
    body                  { "Body for #{headline}" }
    site                  "blogdowntown"
    url                   { "http://blogdowntown.com/2011/11/6494-#{headline.parameterize}" }

    published

    after(:create) do |s|
      Job::Indexer.perform s.class.name, s.id, :create
      ContentBase.es_client.indices.refresh index:"_all"
    end

  end
end
