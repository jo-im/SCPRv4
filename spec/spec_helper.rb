ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
Dir[Rails.root.join("spec/fixtures/db/*.rb")].each { |f| require f }
silence_stream(STDOUT) { FixtureMigration.new.up }

require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'
require 'capybara/rspec'

require 'elasticsearch/extensions/test/cluster'

ES_PORT = (ENV['TEST_CLUSTER_PORT'] || 9200)

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Load all of our test classes, their indices, and their factories.
Dir[Rails.root.join("spec/fixtures/models/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/fixtures/factories/*.rb")].each { |f| require f }

WebMock.disable_net_connect!(allow:["127.0.0.1:#{ES_PORT}","localhost:#{ES_PORT}", "0.0.0.0:#{ES_PORT}"])

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.order = 'random'

  config.exclude_pattern = [
    "spec/controllers/api/public/v2/articles_controller_spec.rb",
    "spec/features/outpost/manage_news_stories_spec.rb",
    "spec/controllers/api/public/v3/articles_controller_spec.rb"
  ]

  config.mock_with :rspec do |c|
    c.syntax = [:should,:expect]
  end

  config.expect_with :rspec do |c|
    c.syntax = [:should,:expect]
  end

  config.infer_spec_type_from_file_location!

  config.include ActionView::TestCase::Behavior, file_path: %r{spec/presenters}

  config.include FactoryGirl::Syntax::Methods
  config.include RemoteStubs
  config.include PresenterHelper
  config.include DatePathHelper
  config.include AudioCleanup
  config.include FormFillers,           type: :feature
  config.include AuthenticationHelper,  type: :feature
  config.include FactoryAttributesBuilder
  config.include ElasticsearchHelper

#  DatabaseCleaner.strategy = :transaction

  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
    load "#{Rails.root}/db/seeds.rb"

    DatabaseCleaner.strategy = :transaction

    FileUtils.rm_rf(
      Rails.configuration.x.scpr.media_root.join("audio/upload")
    )
  end

  config.before :suite do
    ContentBase.class_variable_set :@@es_client, Elasticsearch::Client.new(
      hosts:              ["127.0.0.1:#{ES_PORT}"],
      retry_on_failure:   0,
      reload_connections: false,
    )

    Elasticsearch::Model.client = ContentBase.es_client

    erase_test_indices

    Article._put_article_mapping
  end

  config.after :suite do
    erase_test_indices
  end

  es_i = 0
  config.around(:each) do |ex|
    ContentBase.class_variable_set :@@es_index, ES_ARTICLES_INDEX+"-#{es_i}"
    es_i += 1

    if ex.metadata[:indexing]
      Resque.run_in_tests = (Resque.run_in_tests + [Job::Indexer]).uniq
    end

    DatabaseCleaner.cleaning do
      ex.run
    end

    Resque.run_in_tests.delete(Job::Indexer)
  end

  config.before :all do
    DeferredGarbageCollection.start
  end

  config.before :each do
    WebMock.reset!

    stub_request(:get, %r|a\.scpr\.org\/api\/outputs|).to_return({
      :body => load_fixture("api/assethost/outputs.json"),
      :headers => {
        :content_type => "application/json"
      }
    })

    stub_request(:get, %r|a\.scpr\.org\/api\/assets|).to_return({
      :body => load_fixture("api/assethost/asset.json"),
      :headers => {
        :content_type => "application/json"
      }
    })

    stub_request(:post, %r|a\.scpr\.org\/api\/assets|).to_return({
      :body => load_fixture("api/assethost/asset.json"),
      :headers => {
        :content_type => "application/json"
      }
    })

    stub_request(:get, %r|\.mp3\z|).to_return({
      :headers => {
        :content_type => 'audio/mpeg',
      },
      :body         => load_fixture('media/audio/2sec.mp3')
    })

    stub_request(:get, %r|cms\.megaphone\.fm\/|).to_return({
      :body => "{}",
      :headers => {
        :content_type => "application/json"
      }
    })
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after :each do
    Rails.cache.clear
    ActionMailer::Base.deliveries.clear
  end

  config.after :all do
    DeferredGarbageCollection.reconsider
    DatabaseCleaner.clean_with(:truncation,{ except: STATIC_TABLES })
  end

  config.after :suite do
    DatabaseCleaner.clean_with :truncation
  end
end

public

def erase_test_indices
  ContentBase.es_client.indices.segments["indices"].keys.each do |index|
    if index.match(ES_ARTICLES_INDEX)
      ContentBase.es_client.indices.delete index: index
    end
  end
end

