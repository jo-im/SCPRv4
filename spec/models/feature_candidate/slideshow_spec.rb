require 'spec_helper'

describe FeatureCandidate::Slideshow do
  let(:category) { create :category }

  before(:each) { reset_es;create :show_segment }

  describe '#content' do
    it "returns the latest slideshow article in this category" do
      story1 = create :news_story,
        category: category, feature: :slideshow

      FeatureCandidate::Slideshow.new(category).content.should eq story1.to_article
    end

    it "excludes passed-in articles" do
      story1 = create :news_story,
        category: category, feature: :slideshow, published_at: 1.week.ago

      story2 = create :news_story,
        category: category, feature: :slideshow, published_at: 1.month.ago

      FeatureCandidate::Slideshow.new(category, exclude: story1)
      .content.should eq story2.to_article
    end

    it "is nil if no articles are available" do
      FeatureCandidate::Slideshow.new(category).content.should be_nil
    end
  end

  describe '#score' do
    it 'is the calculated score' do
      story1 = create :news_story,
        category: category, feature: :slideshow

      FeatureCandidate::Slideshow.new(category).score.should be > 0
    end

    it "is higher if there are more slides" do
      story1 = create :news_story,
        category: category, feature: :slideshow
      create :asset, content: story1

      # bleh
      score1 = nil
      score2 = nil

      score1 = FeatureCandidate::Slideshow.new(category).score

      story1.destroy

      story2 = create :news_story,
        category: category, feature: :slideshow
      create_list :asset, 2, content: story2

      score2 = FeatureCandidate::Slideshow.new(category).score

      score2.should be > score1
    end

    it "is nil if content is nil" do
      FeatureCandidate::Slideshow.new(category).score.should be_nil
    end
  end
end
