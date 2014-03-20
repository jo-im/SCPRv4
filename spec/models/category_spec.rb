require "spec_helper"

describe Category do
  describe '#category_articles' do
    it 'orders by position' do
      category = build :category
      category.category_articles.to_sql.should match /order by position/i
    end
  end

  describe '#quotes' do
    it 'orders by created_at desc' do
      category = build :category
      category.quotes.to_sql.should match /order by created_at desc/i
    end
  end

  describe '::previews' do
    let(:category) { create :category_news }
    let(:other_category) { create :category_not_news }

    sphinx_spec

    it "returns a list of previews for all categories with no category option" do
      create :news_story, category: category
      create :news_story, category: other_category

      index_sphinx

      previews = Category.previews

      # Meh
      previews.size.should eq 2
      previews.first.should be_a CategoryPreview
    end

    it "only generates previews for the passed-in categories" do
      create :news_story, category: category
      create :news_story, category: other_category

      index_sphinx

      previews = Category.previews(categories: [category])
      previews.size.should eq 1
    end

    it "doesn't include categories with no articles" do
      story1 = create :news_story, category: category
      other_category # touch

      index_sphinx

      ts_retry(2) do
        Category.previews.map(&:category).should eq [category]
      end
    end

    it 'sorts previews by the descending article publish timestamps' do
      story1 = create :news_story, category: category, published_at: 1.month.ago
      story2 = create :news_story, category: other_category, published_at: Time.now

      index_sphinx

      ts_retry(2) do
        Category.previews.first.category.should eq other_category
      end
    end
  end

  describe '#featured_articles' do
    it 'turns all of the items into articles' do
      category = create :category_news
      story = create :news_story
      category_article = create :category_article, category: category, article: story

      category.featured_articles.map(&:class).uniq.should eq [Article]
    end

    it "only gets published articles" do
      category = create :category_news
      story_published = create :news_story, :published
      story_unpublished = create :news_story, :draft

      category.category_articles.create(article: story_published)
      category.category_articles.create(article: story_unpublished)

      category.featured_articles.should eq [story_published].map(&:to_article)
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
        category.content.to_a.should eq [story1]
      end
    end

    it "excludes any passed-in objects" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category

      index_sphinx

      ts_retry(2) do
        category.content(page: 1, per_page: 10, exclude: story2).to_a
        .should eq [story1]
      end
    end

    it "excludes an array of passed-in objects" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      story3 = create :news_story, category: category
      index_sphinx

      ts_retry(2) do
        category.content(page: 1, per_page: 10, exclude: [story2,story3]).to_a
        .should eq [story1]
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
