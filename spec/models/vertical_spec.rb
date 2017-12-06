require 'spec_helper'

describe Vertical do
  describe '::interactive_select_collection' do
    it "maps and titleizes" do
      Vertical.interactive_select_collection.should include ["Beams", 0]
    end
  end

  describe '#vertical_articles' do
    it 'orders by position' do
      vertical = build :vertical
      vertical.vertical_articles.to_sql.should match /order by position/i
    end
  end

  describe '#featured_articles' do
    it 'turns all of the items into articles' do
      vertical = create :vertical
      story = create :news_story
      vertical_article = create :vertical_article, vertical: vertical, article: story

      vertical.featured_articles.map(&:class).uniq.should eq [NewsStory]
    end

    it "only gets published articles" do
      vertical = create :vertical
      story_published = create :news_story, :published
      story_unpublished = create :news_story, :draft

      vertical.vertical_articles.create(article: story_published)
      vertical.vertical_articles.create(article: story_unpublished)

      vertical.featured_articles.should eq [story_published]
    end
  end

  describe '#featured_interactive_style' do
    it "is the style" do
      vertical = build :vertical, featured_interactive_style_id: 0
      vertical.featured_interactive_style.should eq 'beams'
    end
  end
end
