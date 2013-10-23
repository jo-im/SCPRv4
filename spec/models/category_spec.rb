require "spec_helper"

describe Category do
  describe '::previews' do
    it "returns a list of previews for all categories" do
      categories = create_list :category_news, 2
      previews = Category.previews

      # Meh
      previews.size.should eq 2
      previews.first.should be_a CategoryPreview
    end
  end

  describe '#content' do
    let(:category) { create :category_news }
    sphinx_spec

    it "returns content for this category" do
      other_category = create :category_news
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      index_sphinx

      ts_retry(2) do
        category.content.should eq [story1].map(&:to_article)
      end
    end

    it "excludes any passed-in objects" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category

      index_sphinx

      ts_retry(2) do
        category.content(page: 1, per_page: 10, exclude: story2)
        .should eq [story1].map(&:to_article)
      end
    end

    it "returns an empty array if the page * per_page is greater than Thinking Sphinx's max_matches" do
      category.content(page: 101).should be_blank
    end
  end

  describe '#preview' do
    it 'creates a preview for the category' do
      category = create :category_news

      # meeeeehhhhhh
      category.preview.should be_a CategoryPreview
      category.preview.category.should eq category
    end
  end
end
