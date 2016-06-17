require 'spec_helper'

describe CategoryPreview, :indexing do

  before(:each) do
    create :show_segment
  end

  let(:category) { create :category }
  let(:other_category) { create :category }

  describe '#category' do
    it 'is the passed-in category' do
      preview = CategoryPreview.new(category)
      preview.category.should eq category
    end
  end

  describe '#articles' do
    it "only gets articles from this category" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      preview = CategoryPreview.new(category)
      preview.articles.should eq [story1].map(&:to_article)
    end

    it 'excludes any passed-in objects' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      story3 = create :news_story, category: other_category

      preview = CategoryPreview.new(category, exclude: [story2])
      # We should actually test that story2 is not included, but this
      # tests the same thing plus makes sure it's not a false positive.
      preview.articles.should eq [story1].map(&:to_article)
    end

    it "uses the limit option" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category

      preview = CategoryPreview.new(category, limit: 1)
      preview.articles.should eq [story1].map(&:to_article)
    end

    it 'uses the default limit if no limit is passed in' do
      stories = create_list :news_story, 6, category: category

      preview = CategoryPreview.new(category)
      preview.articles.map(&:obj_key).sort.should eq stories.first(5).map(&:obj_key).sort
    end
  end

  describe '#candidates' do
    it 'is the feature candidates' do
      story1 = create :news_story, category: category

      preview = CategoryPreview.new(category)
      preview.candidates.should_not be_empty
    end
  end

  describe '#top_article' do
    it 'selects the first article with assets' do
      story1  = create :news_story, category: category, published_at: 1.month.ago
      story2  = create :news_story, category: category, published_at: 2.months.ago
      create :asset, content: story2

      preview = CategoryPreview.new(category)

      preview.top_article.should eq story2.to_article
    end

    it 'is nil if no articles have assets' do
      story1 = create :news_story, category: category
      preview = CategoryPreview.new(category)
      preview.top_article.should be_nil
    end
  end

  describe '#bottom_articles' do
    it 'is the articles except the top article' do
      story1  = create :news_story, category: category, published_at: 1.month.ago
      story2  = create :news_story, category: category, published_at: 2.months.ago
      create :asset, content: story2

      preview = CategoryPreview.new(category)
      preview.bottom_articles.should eq [story1].map(&:to_article)
    end
  end

  describe '#featured_object' do
    it 'returns the candidate with the highest score' do
      # Slideshow
      story1 = create :news_story, category: category
      create :asset, content: story1

      # Segment
      segment = create :show_segment

      # Featured Comment
      bucket = create :featured_comment_bucket
      category.comment_bucket = bucket
      comment = create :featured_comment, bucket: bucket, content: segment

      preview = CategoryPreview.new(category)
      preview.featured_object.should eq comment
    end
  end
end
