require 'spec_helper'

describe Quote do
  describe '::published' do
    it "gets published quotes ordered in reverse chron" do
      quote1 = create :quote, :published, created_at: 1.month.ago
      quote2 = create :quote, :published, created_at: 1.week.ago
      quote3 = create :quote, :draft

      Quote.published.should eq [quote2, quote1]
    end
  end

  describe '::status_select_collection' do
    it "is an array of statuses" do
      Quote.status_select_collection.should be_a Array
    end
  end

  describe 'validations' do
    it "validates that the content exists" do
      quote = build :quote, :published, content_type: "Event", content_id: "999"
      quote.should_not be_valid
      quote.errors.keys.should eq [:content_id]
    end

    it "validates that the content is published" do
      story = build :news_story, :draft
      entry = build :blog_entry, :published

      quote1 = build :quote, :published, content: story
      quote2 = build :quote, :published, content: entry

      quote1.should_not be_valid
      quote1.errors.keys.should eq [:content_id]

      quote2.should be_valid
    end
  end

  describe '#article' do
    it "is the content to_article" do
      story = build :news_story, :published
      quote = build :quote, content: story
      quote.article.should eq story.to_article
    end
  end

  describe '#published?' do
    it 'is true if the status is published' do
      quote = build :quote, :published
      quote.published?.should eq true
    end

    it 'is false if the status is not published' do
      quote = build :quote, :draft
      quote.published?.should eq false
    end
  end

  describe '#status_text' do
    it "is the name of the status" do
      quote = build :quote, :published
      quote.status_text.should eq Quote::STATUS_TEXT[Quote::STATUS_LIVE]
    end
  end
end
