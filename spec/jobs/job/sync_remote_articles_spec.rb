require 'spec_helper'

describe Job::SyncRemoteArticles do
  subject { described_class }
  it { subject.queue.should eq "scprv4:mid_priority" }

  before :each do
    stub_request(:get, %r|api\.npr|).to_return({
      :content_type => "application/json",
      :body => load_fixture('api/npr/stories.json')
    })

    PMP::CollectionDocument.any_instance.stub(:oauth_token) { "token" }

    stub_request(:get, %r|pmp\.io/?$|).to_return({
      :content_type => "application/json",
      :body => load_fixture('api/pmp/root.json')
    })

    stub_request(:get, %r|pmp\.io/docs|).to_return({
      :content_type => "application/json",
      :body => load_fixture('api/pmp/marketplace_stories.json')
    })
  end

  it "syncs the remote articles" do
    RemoteArticle.count.should eq 0
    Job::SyncRemoteArticles.perform
    RemoteArticle.count.should be > 0
  end
end
