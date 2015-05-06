require 'spec_helper'

describe Tag do
  it { should have_many :taggings }

  describe '#articles' do
    it "returns all articles for this tag" do
      tag = create :tag
      news_story = build :news_story
      news_story.tags << tag
      news_story.save!

      tag.articles.should eq [news_story].map(&:to_article)
    end
  end

  describe '#update_timestamps' do
    news_stories = []
    tag = nil
    before(:each) do
      tag = create :tag
      news_stories = []
      10.times do 
        news_story = build :news_story
        news_story.tags << tag
        news_story.save
        news_stories << news_story.reload
      end
      news_stories.sort_by!(&:published_at)
      tag.update_timestamps
    end
    it "updates the began_at and most_recent_at fields to their correct values" do
      expect(tag.began_at).to eq news_stories.first.published_at
      expect(tag.most_recent_at).to eq news_stories.last.published_at
    end
    it "adds a most_recent_at timestamp that is greater than the began_at timestamp" do
      expect(tag.most_recent_at).to be > tag.began_at
    end
  end
end
