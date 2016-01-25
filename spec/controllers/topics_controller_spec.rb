require 'spec_helper'

describe TopicsController, :indexing do
  render_views

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

    it "raises an error if the slug isn't found" do
      -> {
        get :show, slug: "no"
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end
end
