require "spec_helper"

describe BetterHomepage, :indexing do
  describe '#content' do
    it 'orders by position' do
      homepage = build :better_homepage
      homepage.content.to_sql.should match /order by position/i
    end
  end

  describe '#publish' do
    it 'sets the status to published' do
      homepage = create :better_homepage, :pending
      homepage.published?.should eq false
      homepage.publish

      homepage.reload.published?.should eq true
    end
  end

  describe '#category_previews' do
    let(:category) { create :category }
    let(:other_category) { create :category }
    let(:homepage) { create :better_homepage }

    before(:all) do
      create :show_segment
    end

    it 'returns previews for all categories' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      homepage.category_previews.size.should eq 2
    end

    it 'excludes articles from this homepage' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      homepage.content.create(content: story1)

      homepage.category_previews.first.articles.map(&:obj_key)
      .should eq [story2.obj_key]
    end
  end
end
