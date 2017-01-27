require 'spec_helper'

describe Job::FetchMarketplaceArticles do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  before :each do
    stub_request(:get, Job::FetchMarketplaceArticles::RSS_URL)
    .to_return({
      :headers => {
        :content_type   => "text/xml"
      },
      :body           => load_fixture('rss/marketplace.xml')
    })
  end

  describe '::perform' do
    it "Caches the first four marketplace feed items" do
      Job::FetchMarketplaceArticles.perform
      marketplace_articles = Rails.cache.read("views/business/marketplace")

      marketplace_articles.should match %r{When the best advice comes from}
      marketplace_articles.should match %r{Who wants to be bigger than the}
      marketplace_articles.should match %r{New York parents opt out of}
      marketplace_articles.should match %r{If Clippers are for sale}
      # Doesn't match the fifth...
      marketplace_articles.should_not match %r{The shrinking board of Fed governors}
    end
  end
end
