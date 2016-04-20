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

  describe '#pmp_alias' do
    it "defaults to the slug" do
      tag = create :tag
      expect(tag.pmp_alias).to eq tag.slug 
    end
    it "assigns a custom alias" do
      tag = create :tag
      tag.pmp_alias = "green-eggs-and-ham"
      tag.save && tag.reload
      expect(tag.pmp_alias).to eq "green-eggs-and-ham"
    end
  end
end
