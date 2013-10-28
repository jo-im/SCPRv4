require 'spec_helper'

describe FeatureCandidate::Slideshow do
  let(:category) { create :category_news }

  describe '#content' do
    sphinx_spec

    it "returns the latest slideshow article in this category" do
      story1 = create :news_story, category: category, story_asset_scheme: "slideshow"

      index_sphinx

      ts_retry(2) do
        FeatureCandidate::Slideshow.new(category).content.should eq story1.to_article
      end
    end

    it "excludes passed-in articles" do
      story1 = create :news_story,
        category: category, story_asset_scheme: "slideshow", published_at: 1.week.ago

      story2 = create :news_story,
        category: category, story_asset_scheme: "slideshow", published_at: 1.month.ago

      index_sphinx

      ts_retry(2) do
        FeatureCandidate::Slideshow.new(category, exclude: story1)
        .content.should eq story2.to_article
      end
    end

    it "is nil if no articles are available" do
      FeatureCandidate::Slideshow.new(category).content.should be_nil
    end
  end

  describe '#score' do
    sphinx_spec

    it 'is the calculated score' do
      story1 = create :news_story, category: category, story_asset_scheme: "slideshow"

      index_sphinx

      ts_retry(2) do
        FeatureCandidate::Slideshow.new(category).score.should be > 0
      end
    end

    it "is higher if there are more slides" do
      story1 = create :news_story, category: category, story_asset_scheme: "slideshow"
      create :asset, content: story1

      # bleh
      score1 = nil
      score2 = nil

      index_sphinx

      score1 = FeatureCandidate::Slideshow.new(category).score

      story1.destroy

      story2 = create :news_story, category: category, story_asset_scheme: "slideshow"
      create_list :asset, 2, content: story2

      index_sphinx

      score2 = FeatureCandidate::Slideshow.new(category).score

      score2.should be > score1
    end

    it "is nil if content is nil" do
      FeatureCandidate::Slideshow.new(category).score.should be_nil
    end
  end
end
