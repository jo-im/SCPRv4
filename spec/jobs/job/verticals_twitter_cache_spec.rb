require "spec_helper"

describe Job::VerticalsTwitterCache do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  describe '::perform' do
    it 'caches the tweet block' do
      bio = create :bio, twitter_handle: "kpcc"
      category = create :category, is_active: true, slug: "politics"
      category.bios << bio

      stub_request(:get, %r|twitter\.com|).to_return({
        :body => load_fixture("api/twitter/user_timeline.json"),
        :content_type => "application/json"
      })

      Rails.cache.read("verticals/#{category.slug}/twitter_feed").should be_nil
      Job::VerticalsTwitterCache.perform
      Rails.cache.read("verticals/#{category.slug}/twitter_feed").should_not be_nil
    end
  end
end
