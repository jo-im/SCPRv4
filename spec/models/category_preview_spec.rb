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
    sphinx_spec

    it "only gets articles from this category" do
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
        preview = CategoryPreview.new(category, exclude: [story2])
        # We should actually test that story2 is not included, but this
        # tests the same thing plus makes sure it's not a false positive.
        preview.articles.should eq [story1].map(&:to_article)
      end
    end

    it "uses the limit option" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category, limit: 1)
        preview.articles.should eq [story1].map(&:to_article)
      end
    end

    it 'uses the default limit if no limit is passed in' do
      stories = create_list :news_story, 6, category: category

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.articles.sort.should eq stories.first(5).map(&:to_article).sort
      end
    end
  end

  describe '#candidates' do
    sphinx_spec

    it 'is the feature candidates' do
      story1 = create :news_story, category: category

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.candidates.should_not be_empty
      end
    end
  end

  describe '#top_article' do
    sphinx_spec

    it 'selects the first article with assets' do
      story1  = create :news_story, category: category, published_at: 1.month.ago
      story2  = create :news_story, category: category, published_at: 2.months.ago
      create :asset, content: story2

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.top_article.should eq story2.to_article
      end
    end

    it 'is nil if no articles have assets' do
      story1 = create :news_story, category: category
      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.top_article.should be_nil
      end
    end
  end

  describe '#bottom_articles' do
    sphinx_spec

    it 'is the articles except the top article' do
      story1  = create :news_story, category: category, published_at: 1.month.ago
      story2  = create :news_story, category: category, published_at: 2.months.ago
      create :asset, content: story2

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.bottom_articles.should eq [story1].map(&:to_article)
      end
    end
  end

  describe '#feature' do
    it 'returns the candidate with the highest score' do
      # Slideshow
      story1 = create :news_story, category: category
      create :asset, content: story1

      # Segment
      segment = create :show_segment

      # Featured Comment 
      bucket = create :featured_comment_bucket
      category.comment_bucket = bucket
      comment = create :featured_comment, :published,
        bucket: bucket, content: segment

      index_sphinx

      ts_retry(2) do
        preview = CategoryPreview.new(category)
        preview.feature.should eq comment
      end
    end
  end
end
