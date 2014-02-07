require "spec_helper"

describe Job::TwitterCache do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  describe "::perform" do
    let(:args) do
      [
        "KPCCForum",
        "/shared/widgets/cached/tweets",
        "twitter:KPCCForum"
      ]
    end

    it "doesn't do anything if tweets are blank" do
      Rails.cache.fetch("twitter:KPCCForum").should be_nil

      stub_request(:get, %r|twitter\.com|).to_return({
        :body => load_fixture("api/empty_array.json"),
        :content_type => "application/json"
      })

      Job::TwitterCache.perform(*args)
      Rails.cache.fetch("twitter:KPCCForum").should be_nil
    end

    it "caches if tweets are present" do
      Rails.cache.fetch("twitter:KPCCForum").should be_nil

      stub_request(:get, %r|twitter\.com|).to_return({
        :body => load_fixture("api/twitter/user_timeline.json"),
        :content_type => "application/json"
      })

      Job::TwitterCache.perform(*args)

      tweets = Rails.cache.fetch("twitter:KPCCForum")
      tweets.should be_present
      tweets.should match /Introducing the Twitter Certified Products Program/
    end
  end
end
