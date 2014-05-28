require 'spec_helper'

describe Quote do
  subject { build :quote }

  describe '#content' do
    it 'gets published content' do
      quote = build :quote
      story = create :news_story, :published
      quote.content = story
      quote.save!

      quote.content(true).should eq story
    end

    it "doesn't get unpublished content" do
      quote = build :quote
      story = create :news_story, :draft
      quote.content = story
      quote.save!

      quote.content(true).should be_nil
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
