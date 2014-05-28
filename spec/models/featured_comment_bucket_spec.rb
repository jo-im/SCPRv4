require "spec_helper"

describe FeaturedCommentBucket do
  describe '#comments' do
    it "orders by created_at desc" do
      bucket = build :featured_comment_bucket
      bucket.comments.to_sql.should match /order by created_at desc/i
    end
  end

  describe "associations" do
    it { should have_many(:comments).class_name("FeaturedComment") }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end
end
