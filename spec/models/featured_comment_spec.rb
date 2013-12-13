require "spec_helper"

describe FeaturedComment do
  describe '::published' do
    it "gets published comments ordered in reverse chron" do
      comment1 = create :featured_comment, :published, created_at: 1.month.ago
      comment2 = create :featured_comment, :published, created_at: 1.week.ago
      comment3 = create :featured_comment, :unpublished

      FeaturedComment.published.should eq [comment2, comment1]
    end
  end

  describe '#article' do
    it "is the content to_article" do
      story = build :news_story, :published
      comment = build :featured_comment, content: story
      comment.article.should eq story.to_article
    end
  end
end
