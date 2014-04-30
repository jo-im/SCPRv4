require 'spec_helper'
require 'rss'
describe Job::FetchMarketplaceArticles do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  before :each do
    stub_request(:get, %r{http://www.marketplace.org/latest-stories/long-feed.xml}).to_return({
      :content_type   => 'text/xml',
      :body           => load_fixture('marketplace.xml')
    })
  end
  describe '::perform' do
    it "fetches and parses the Marketplace RSS feed, then writes to cache" do
      Job::FetchMarketplaceArticles.perform
      marketplace_articles = Rails.cache.read("business/marketplace")
      marketplace_articles.first.title.should match /Drought puts California rice in a sticky situation/
    end
  end
end

