require 'spec_helper'

describe IssuesController, :indexing do
  render_views

  describe 'GET /issues' do
    it 'sets @tags to all active tags' do
      tags = create_list :tag, 3

      get :index

      assigns(:tags).should eq tags.sort_by(&:title)
    end

    it "assigns popular articles" do
      article = create(:news_story).to_article
      Rails.cache.write("popular/viewed", [article])

      get :index
      assigns(:popular_articles).should eq [article]
    end
  end

  describe 'GET show' do
    it 'sets tag' do
      tag = create :tag
      get :show, slug: tag.slug
      assigns(:tag).should eq tag
    end

    it "sets articles" do
      tag = create :tag
      article = build :news_story
      article.tags << tag
      article.save!

      get :show, slug: tag.slug
      assigns(:articles).should eq [article].map(&:to_article)
    end

    it "gets the tag by slug" do
      tag = create :tag
      get :show, slug: tag.slug
      assigns(:tag).should eq tag
    end

    it "assigns popular articles" do
      article = create(:news_story).to_article
      Rails.cache.write("popular/viewed", [article])

      tag = create :tag
      get :show, slug: tag.slug
      assigns(:popular_articles).should eq [article]
    end

    it "raises an error if the slug isn't found" do
      -> {
        get :show, slug: "no"
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end
end
