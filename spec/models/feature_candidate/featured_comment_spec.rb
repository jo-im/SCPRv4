require 'spec_helper'

describe FeatureCandidate::FeaturedComment do
  let(:bucket) { create :featured_comment_bucket }
  let(:category) { create :category_news, comment_bucket: bucket }

  describe '#content' do
    it "is the first featured comment for the category's bucket" do
      comment = create :featured_comment, :published, bucket: bucket

      candidate = FeatureCandidate::FeaturedComment.new(category)
      candidate.content.should eq comment
    end
  end
end
