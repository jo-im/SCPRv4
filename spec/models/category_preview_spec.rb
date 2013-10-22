require 'spec_helper'

describe CategoryPreview do
  let(:category) { create :category_news }
  let(:other_category) { create :category_not_news }

  describe '#category' do
    it 'is the passed-in category' do
      preview = CategoryPreview.new(category)
      preview.category.should eq category
    end
  end

  describe '#articles' do
    before :all do
      setup_sphinx
    end

    after :all do
      teardown_sphinx
    end

    it "only gets articles from this category", focus: true do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.articles.should eq [story1].map(&:to_article)
      end
    end

    it 'excludes any passed-in objects' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      story3 = create :news_story, category: other_category

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category, exclude: story2)
        preview.articles.should eq [story1].map(&:to_article)
      end
    end
  end
end
