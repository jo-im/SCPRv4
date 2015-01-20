require 'spec_helper'

describe Job::FetchMarketplaceArticles do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  before :each do
    stub_request(:get, "http://www.marketplace.org/latest-stories/long-feed.xml")
    .to_return({
      :content_type   => 'text/xml',
      :body           => load_fixture('rss/marketplace.xml')
    })
  end

  describe '::perform' do
    it "Caches the first two marketplace feed items" do
      Job::FetchMarketplaceArticles.perform
      marketplace_articles = Rails.cache.read("views/business/marketplace")

      marketplace_articles.should match %r{When the best advice comes from}
      marketplace_articles.should match %r{Who wants to be bigger than the}
      # Doesn't match the third...
      marketplace_articles.should_not match %r{New York parents opt out of}
    end
  end
end
