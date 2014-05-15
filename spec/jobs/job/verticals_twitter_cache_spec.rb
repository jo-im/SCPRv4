require "spec_helper"

describe Job::VerticalsTwitterCache do
  subject { described_class }
  it { subject.queue.should eq "scprv4:low_priority" }

  describe '::perform' do
    it 'caches the tweet block' do
      bio = create :bio, twitter_handle: "kpcc"
      vertical = create :vertical, slug: "politics"
      vertical.reporters << bio

      stub_request(:get, %r|twitter\.com|).to_return({
        :body => load_fixture("api/twitter/user_timeline.json"),
        :content_type => "application/json"
      })

      Rails.cache.read("verticals/#{vertical.slug}/twitter_feed").should be_nil
      Job::VerticalsTwitterCache.perform
      Rails.cache.read("verticals/#{vertical.slug}/twitter_feed").should_not be_nil
    end
  end
end
