require "spec_helper"

describe FeedsController do
  before(:all) do
    create :news_story, 3
  end

  describe "GET /all_news" do
    it "doesn't render a layout" do
      get :all_news
      response.should render_template(layout: false)
    end

    it "adds XML content-type to header" do
      get :all_news
      response.header["Content-Type"].should eq "text/xml"
    end

    it "returns a string" do
      get :all_news
      response.body.should be_a String
    end

    it "uses ContentBase to populate @content" do
      get :all_news
      assigns(:content).should_not be_blank
    end
  end

  describe "GET /npr_ingest" do
    before :each do
      take_two = create :kpcc_program, is_segmented: false, slug: 'take-two'
      take_two_episode = create :show_episode, :published, show: take_two
      take_two_segment = create_list :show_rundown, 2, episode: take_two_episode

      the_frame = create :kpcc_program, is_segmented: false, slug: 'the-frame'
      the_frame_episode = create :show_episode, :published, show: the_frame
      the_frame_segment = create_list :show_rundown, 2, episode: the_frame_episode
    end
    it "doesn't render a layout" do
      get :npr_ingest
      response.should render_template(layout: false)
    end

    it "adds XML content-type to header" do
      get :npr_ingest
      response.header["Content-Type"].should eq "text/xml"
    end

    it "populates segments" do
      get :npr_ingest
      assigns(:segments).should_not be_blank
    end
  end
end
