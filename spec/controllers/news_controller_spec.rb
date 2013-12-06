require "spec_helper"

describe NewsController do
  describe "GET /story" do
    describe 'view' do
      render_views

      it 'renders the view' do
        story   = create :news_story
        bio     = create :bio, twitter_handle: "bryanricker"
        byline  = create :byline, content: story, user: bio

        get :story, story.route_hash
      end
    end

    describe 'controller' do
      before :each do
        @story   = create :news_story
        @bio     = create :bio, twitter_handle: "bryanricker"
        @byline  = create :byline, content: @story, user: @bio
      end

      it "renders the layout" do
        get :story, @story.route_hash
        response.should render_template "layouts/vertical"
      end

      it "assigns @story" do
        story = create :news_story, :published
        get :story, story.route_hash
        assigns(:story).should eq story
      end

      it "raises RecordNotFound if story not found" do
        story = create :news_story, :published
        -> {
          get :story, { id: "999999", slug: story.slug }.merge!(date_path(story.published_at))
        }.should raise_error ActiveRecord::RecordNotFound
      end
      context "for popular articles" do
        let(:articles) { create_list(:blog_entry, 3).map(&:to_article) }

        before :each do
          Rails.cache.write("popular/viewed", articles)
          get :story, @story.route_hash
        end

        it 'assigns @popular_articles' do
          assigns(:popular_articles).should eq articles
        end
      end
    end
  end
end
