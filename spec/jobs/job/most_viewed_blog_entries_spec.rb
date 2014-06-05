require 'spec_helper'

describe Job::MostViewedBlogEntries do
  subject {described_class }
  it { subject.queue.should eq "scprv4:low_priority" }

  describe '::perform' do
    it "fetches and parses the analytics, then writes to cache" do
      blog = create :blog, slug: "patt-morrison"
      story = create :blog_entry, :published, blog: blog

      Job::MostViewedBlogEntries.any_instance.should_receive(:oauth_token)
      Job::MostViewedBlogEntries.any_instance.should_receive(:fetch).and_return(
        JSON.parse(load_fixture("api/google/analytics_most_viewed_blog_entries.json")))
      ContentBase.should_receive(:obj_by_url)
        .with("/news/2013/11/17/1/tornadoes-in-illinois-cause-severe-damage/")
        .and_return(story)

      Job::MostViewedBlogEntries.perform

      popular_entry = Rails.cache.read("popular/patt-morrison")
      popular_entry.should eq story.to_article

    end
  end
end
