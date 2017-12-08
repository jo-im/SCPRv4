require "spec_helper"

describe NewsController do
  describe "story" do
    render_views

    before :each do
      @story   = create :news_story
      @bio     = create :bio, twitter_handle: "bryanricker"
      @byline  = create :byline, content: @story, user: @bio
    end

    it 'renders the view' do
      get :story, @story.route_hash
    end

    it 'renders audio if it is available' do
      audio = create_list :audio, 2, :direct, :live, content: @story

      get :story, @story.route_hash
      response.status.should eq 200
    end

    it "renders the layout" do
      get :story, @story.route_hash
      response.should render_template "application"
    end

    it "assigns @story" do
      story = create :news_story, :published
      get :story, story.route_hash
      assigns(:story).should eq story
    end

    it "raises an UrlGenerationError if story slug does not exist" do
      story = create :news_story, :published
      -> {
        get :story, { id: story.id, slug: '' }.merge!(date_path(story.published_at))
      }.should raise_error ActionController::UrlGenerationError
    end
  end
end
