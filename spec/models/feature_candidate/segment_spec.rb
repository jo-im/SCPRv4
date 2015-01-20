require 'spec_helper'

describe FeatureCandidate::Segment do
  let(:category) { create :category }

  describe '#content' do
    it 'is the latest segment in this category' do
      segment1 = create :show_segment, category: category, published_at: 1.month.ago
      segment2 = create :show_segment, category: category, published_at: 1.week.ago

      FeatureCandidate::Segment.new(category).content.should eq segment2.to_article
    end

    it 'excludes passed-in articles' do
      segment1 = create :show_segment, category: category, published_at: 1.month.ago
      segment2 = create :show_segment, category: category, published_at: 1.week.ago

      FeatureCandidate::Segment.new(category, exclude: segment2)
      .content.should eq segment1.to_article
    end

    it "is nil if no content is available" do
      FeatureCandidate::Segment.new(category).content.should be_nil
    end
  end

  describe '#score' do
    it "is the calculated score" do
      segment = create :show_segment, category: category

      FeatureCandidate::Segment.new(category).score.should be > 0
    end

    it "is nil if content is empty" do
      FeatureCandidate::Segment.new(category).score.should be_nil
    end
  end
end
