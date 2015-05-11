require "spec_helper"

describe Category, :indexing do
  before(:each) do
    # create a segment so that our FeatureCandidate::Segment lookup works
    # (it otherwise fails due to a missing mapping)
    create :show_segment
  end

  describe '::previews' do
    let(:category) { create :category }
    let(:other_category) { create :category }

    it "returns a list of previews for all categories with no category option" do
      create :news_story, category: category
      create :news_story, category: other_category

      previews = Category.previews

      # Meh
      previews.size.should eq 2
      previews.first.should be_a CategoryPreview
    end

    it "only generates previews for the passed-in categories" do
      create :news_story, category: category
      create :news_story, category: other_category

      previews = Category.previews(categories: [category])
      previews.size.should eq 1
    end

    it "doesn't include categories with no articles" do
      story1 = create :news_story, category: category
      other_category # touch

      Category.previews.map(&:category).should eq [category]
    end

    it 'sorts previews by the descending article publish timestamps' do
      story1 = create :news_story, category: category, published_at: 1.month.ago
      story2 = create :news_story, category: other_category, published_at: Time.zone.now

      Category.previews.first.category.should eq other_category
    end
  end

  describe '#content' do
    let(:category) { create :category }

    it "returns content for this category" do
      other_category = create :category
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      category.content.map(&:obj_key).should eq [story1.obj_key]
    end

    it "excludes any passed-in objects" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category

      category.content(page: 1, per_page: 10, exclude: story2)
      .map(&:obj_key).should eq [story1.obj_key]
    end

    it "excludes an array of passed-in objects" do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      story3 = create :news_story, category: category

      category.content(page: 1, per_page: 10, exclude: [story2,story3])
      .map(&:obj_key).should eq [story1.obj_key]
    end
  end

  describe '#preview' do
    it 'creates a preview for the category' do
      category = create :category

      # meeeeehhhhhh
      category.preview.should be_a CategoryPreview
      category.preview.category.should eq category
    end
  end
end
