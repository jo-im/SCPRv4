require 'spec_helper'

describe Article do
  describe '==' do
    it 'only compares the IDs' do
      article1 = Article.new(id: "article:1")
      article2 = Article.new(id: "article:2")
      article3 = Article.new(id: "article:2") # yes, that's a 2

      article1.should_not eq article2
      article2.should eq article3
    end
  end

  describe 'initialization' do
    let(:article) { Article.new }

    it 'forces assets into an array' do
      article.assets.should eq []
    end

    it 'forces attributions into an array' do
      article.attributions.should eq []
    end

    it 'forces audio into an array' do
      article.audio.should eq []
    end

    it 'forces issues into an array' do
      article.issues.should eq []
    end

  end

  describe '#to_article' do
    it 'is itself' do
      article = Article.new

      article.to_article.should equal article
    end
  end

  describe '#to_abstract' do
    it 'builds a new abstract' do
      article = Article.new
      article.to_abstract.should be_a Abstract
    end
  end

  describe '#asset' do
    it 'is the articles first asset' do
      article   = Article.new
      asset     = build :asset

      article.assets << asset
      article.asset.should eq asset
    end

    it "is a fallback if there is no asset" do
      article = Article.new
      article.asset.should be_a AssetHost::Asset::Fallback
    end
  end

  describe '#updated_at' do
    it "is the original object's updated at" do
      entry = create :blog_entry
      article = entry.to_article

      article.updated_at.should_not eq nil
      article.updated_at.should eq entry.updated_at
    end

    it "is nil if original object is blank" do
      article = Article.new
      article.updated_at.should eq nil
    end
  end

  describe '#cache_key' do
    it "uses the original object" do
      entry = create :blog_entry
      article = entry.to_article

      article.cache_key.should_not eq nil
      article.cache_key.should eq entry.cache_key
    end

    it "is nil if original object is blank" do
      article = Article.new
      article.cache_key.should eq nil
    end
  end

  describe '#issues_in_category' do
    let(:category) { create :category }
    let(:story) { Article.new(category: category) }
    let(:common_issue) { create :issue }

    context 'article and category share one issue' do
      before :each do
        4.times { category.issues << create(:issue) }
        2.times { story.issues << create(:issue) }
        category.issues << common_issue
        story.issues << common_issue
      end

      it 'returns an array with the article they both have in common' do
        story.issues_in_category.count.should eq 1
        story.issues_in_category.first.should eq common_issue
      end
    end

    context 'article and category have no issues in common' do
      before :each do
        4.times { category.issues << create(:issue) }
        2.times { story.issues << create(:issue) }
      end

      it 'returns an empty array' do
        story.issues_in_category.count.should eq 0
      end
    end

    context 'article and category that have no issues at all' do
      it 'returns an empty array' do
        story.issues_in_category.should eq []
      end
    end
  end
end
