require 'spec_helper'

describe Concern::Callbacks::ExpireIngestFeedCacheCallback do
  context "published content" do
    it 'clears the cache on update' do
      story = create :news_story, status: 0

      Rails.cache.write "controller/ingest-feed-controller", "hello world"

      expect(Rails.cache.read("controller/ingest-feed-controller")).to eq "hello world"

      story.update status: 5

      expect(Rails.cache.read("controller/ingest-feed-controller")).to eq nil

    end
  end
  context "non-published content" do
    it 'leaves the cache alone' do
      story = create :news_story, status: 0

      Rails.cache.write "controller/ingest-feed-controller", "hello world"

      expect(Rails.cache.read("controller/ingest-feed-controller")).to eq "hello world"

      story.update body: "hello wurld"

      expect(Rails.cache.read("controller/ingest-feed-controller")).to eq "hello world"

    end
  end
end
