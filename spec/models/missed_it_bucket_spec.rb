require "spec_helper"

describe MissedItBucket do
  describe '#content' do
    it 'orders by position' do
      bucket = build :missed_it_bucket
      bucket.content.to_sql.should match /order by position/i
    end
  end

  describe 'slug generation' do
    subject { create :missed_it_bucket, title: "What What", slug: nil }

    it { subject.slug.should eq "what-what" }
  end
end
