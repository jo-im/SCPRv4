require "spec_helper"

describe FeaturedComment do
  describe '::published' do
    it "gets published comments ordered in reverse chron" do
      comment1 = create :featured_comment, :published, created_at: 1.month.ago
      comment2 = create :featured_comment, :published, created_at: 1.week.ago
      comment3 = create :featured_comment, :draft

      FeaturedComment.published.should eq [comment2, comment1]
    end
  end

  describe '::status_select_collection' do
    it "is an array of statuses" do
      FeaturedComment.status_select_collection.should be_a Array
    end
  end

  describe '#article' do
    it "is the content to_article" do
      story = build :news_story, :published
      comment = build :featured_comment, content: story
      comment.article.should eq story.to_article
    end
  end

  describe '#published?' do
    it 'is true if the status is published' do
      comment = build :featured_comment, :published
      comment.published?.should eq true
    end

    it 'is false if the status is not published' do
      comment = build :featured_comment, :draft
      comment.published?.should eq false
    end
  end

  describe '#status_text' do
    it "is the name of the status" do
      comment = build :featured_comment, :published
      comment.status_text.should eq FeaturedComment::STATUS_TEXT[FeaturedComment::STATUS_LIVE]
    end
  end
end
