require 'spec_helper'

describe Tag, :indexing do
  it { should have_many :taggings }

  describe '#articles' do
    it "returns all articles for this tag" do
      tag = create :tag
      news_story = build :news_story
      news_story.tags << tag
      news_story.save!

      tag.articles.should eq [news_story].map(&:to_article)
    end
  end

  describe '#update_timestamps' do
    tag = nil
    one_day_ago     = 1.day.ago
    four_months_ago = 4.months.ago
    five_months_ago = 5.months.ago
    six_months_ago  = 6.months.ago
    published_at = four_months_ago
    today           = Time.now

    before(:each) do
      tag = create :tag
    end

    context "tag without existing timestamps" do
      it "updates both timestamps to the same published_at value" do
        published_at = Time.now
        tag.update began_at: nil, most_recent_at: nil
        tag.update_timestamps published_at
        expect(tag.began_at).to_not be_nil
        expect(tag.most_recent_at).to_not be_nil
        expect(tag.began_at).to eq(tag.most_recent_at)
      end
    end

    context "tag with existing timestamps" do
      it "updates the began_at if the published_at date is before it" do
        tag.update began_at: five_months_ago, most_recent_at: one_day_ago
        tag.update_timestamps six_months_ago
        expect(tag.began_at).to eq six_months_ago
      end
      it "does not update the began_at if the published_at date is not before it" do
        tag.update began_at: five_months_ago, most_recent_at: one_day_ago
        tag.update_timestamps four_months_ago
        expect(tag.began_at).to eq five_months_ago
      end
      it "updates the most_recent_at if the published_at date is after it" do
        tag.update began_at: five_months_ago, most_recent_at: one_day_ago
        tag.update_timestamps today
        expect(tag.most_recent_at).to eq today
      end
      it "does not update the most_recent_at if the published_at date is not before it" do
        tag.update began_at: five_months_ago, most_recent_at: one_day_ago
        tag.update_timestamps four_months_ago
        expect(tag.most_recent_at).to eq one_day_ago
      end
    end

  end

  describe "#sanitize_tag_type" do
    tag = nil
    before(:each) do
      tag = create :tag
    end
    it "formats and sanitizes tag type upon save" do
      tag.tag_type = " beat  \n"
      tag.save
      expect(tag.tag_type).to eq "Beat"
    end
  end

end
