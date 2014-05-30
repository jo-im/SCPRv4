require 'spec_helper'

describe Tag do
  it { should have_many :taggings }

  describe '#articles' do
    sphinx_spec(num: 0)

    it "returns all articles for this tag" do
      tag = create :tag
      news_story = build :news_story
      news_story.tags << tag
      news_story.save!

      index_sphinx

      ts_retry(2) do
        tag.articles.should eq [news_story].map(&:to_article)
      end
    end
  end
end
