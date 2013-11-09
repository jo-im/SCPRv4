require 'spec_helper'

describe FeatureCandidate::FeaturedComment do
  let(:bucket) { create :featured_comment_bucket }
  let(:category) { create :category_news }

  describe '#content' do
    it "is the first featured comment for the category's bucket" do
      category.comment_bucket = bucket
      comment = create :featured_comment, bucket: bucket

      candidate = FeatureCandidate::FeaturedComment.new(category)
      candidate.content.should eq comment
    end

    it "is nil if the category does not have a bucket" do
      candidate = FeatureCandidate::FeaturedComment.new(category)
      candidate.content.should be_nil
    end
  end

  describe '#score' do
    it "is nil if content is empty" do
      candidate = FeatureCandidate::FeaturedComment.new(category)
      candidate.score.should eq nil
    end

    it "is the calculated score" do
      category.comment_bucket = bucket
      comment = create :featured_comment, bucket: bucket

      candidate = FeatureCandidate::FeaturedComment.new(category)
      candidate.score.should be > 0
    end
  end
end
