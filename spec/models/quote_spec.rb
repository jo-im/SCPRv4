require 'spec_helper'

describe Quote do
  subject { build :quote }
  it { should belong_to(:category) }

  describe '::published' do
    it "gets published quotes ordered in reverse chron" do
      quote1 = create :quote, :published, created_at: 1.month.ago
      quote2 = create :quote, :published, created_at: 1.week.ago
      quote3 = create :quote, :draft

      Quote.published.should eq [quote2, quote1]
    end
  end

  describe '#article' do
    it "is the content to_article" do
      story = build :news_story, :published
      quote = build :quote, content: story
      quote.article.should eq story.to_article
    end
  end
end
