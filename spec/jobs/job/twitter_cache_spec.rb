require "spec_helper"

describe Job::TwitterCache do
  subject { described_class }
  its(:queue) { should eq "scprv4:low_priority" }

  describe "::perform" do
    let(:args) {
      [
        "KPCCForum",
        "/shared/widgets/cached/tweets",
        "twitter:KPCCForum"
      ]
    }

    let(:tweets) { ["tweet1", "tweet2"] }

    it "doesn't do anything if tweets are blank" do
      Rails.cache.fetch("twitter:kpcc").should eq nil

      stub_request(:get, %r|twitter\.com|).to_return({
        :body => nil,
        :content_type => "application/json"
      })

      Job::TwitterCache.perform(*args).should eq nil
      Rails.cache.fetch("twitter:kpcc").should eq nil
    end

    it "caches if tweets are present" do
      stub_request(:get, %r|twitter\.com|).to_return({
        :body => nil,
        :content_type => "application/json"
      })

      Job::TwitterCache.perform(*args).should eq nil
      Rails.cache.fetch("twitter:kpcc").should eq nil
    end
  end
end
