require "spec_helper"

describe Homepage do
  describe '::status_select_collection' do
    it 'is an array of status texts' do
      Homepage.status_select_collection.first[1]
      .should eq Homepage::STATUS_DRAFT
    end
  end

  describe '#published?' do
    it 'is true if status is published' do
      homepage = build :homepage, :published
      homepage.published?.should eq true
    end

    it 'is false if status is not published' do
      homepage = build :homepage, :pending
      homepage.published?.should eq false
    end
  end

  describe '#pending?' do
    it 'is true if status is pending' do
      homepage = build :homepage, :pending
      homepage.pending?.should eq true
    end

    it 'is false if status is not pending' do
      homepage = build :homepage, :published
      homepage.pending?.should eq false
    end
  end

  describe '#status_text' do
    it 'is the human-friendly status' do
      homepage = build :homepage, :published
      homepage.status_text.should be_present
    end
  end

  describe '#publish' do
    it 'sets the status to published' do
      homepage = create :homepage, :pending
      homepage.published?.should eq false
      homepage.publish

      homepage.reload.published?.should eq true
    end
  end

  describe '#category_previews' do
    let(:category) { create :category_news }
    let(:other_category) { create :category_not_news }
    let(:homepage) { create :homepage }

    sphinx_spec

    it 'returns previews for all categories' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: other_category

      index_sphinx

      homepage.category_previews.size.should eq 2
    end

    it 'excludes articles from this homepage' do
      story1 = create :news_story, category: category
      story2 = create :news_story, category: category
      homepage.content.create(content: story1)

      index_sphinx

      homepage.category_previews.first.articles
      .should eq [story2].map(&:to_article)
    end
  end
end
