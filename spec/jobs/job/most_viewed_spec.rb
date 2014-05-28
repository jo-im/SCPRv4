require 'spec_helper'

describe Job::MostViewed do
  subject { described_class }
  it { subject.queue.should eq "scprv4:low_priority" }

  describe '::perform' do
    it "fetches and parses the analytics, then writes to cache" do
      story = create :news_story, :published

      # Not really worth testing
      Job::MostViewed.any_instance.should_receive(:oauth_token)
      Job::MostViewed.any_instance.should_receive(:fetch).and_return(
        JSON.parse(load_fixture("api/google/analytics_most_viewed.json")))

      ContentBase.should_receive(:obj_by_url)
        .with("/news/2013/11/17/1/tornadoes-in-illinois-cause-severe-damage/")
        .and_return(story)

      Job::MostViewed.perform

      popular = Rails.cache.read("popular/viewed")
      popular.should eq [story].map(&:to_article)
    end
  end
end
