require "spec_helper"

describe FeedsController do
  describe "GET /all_news" do
    sphinx_spec(num: 1)

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

    it "uses sphinx to populate @content" do
      get :all_news
      assigns(:content).should_not be_blank
    end
  end

  describe "GET /take_two" do
    before :each do
      take_two = create :kpcc_program, is_segmented: false, slug: 'take-two'
      episode = create :show_episode, :published, show: take_two
      segment = create_list :show_rundown, 2, episode: episode
    end
    it "doesn't render a layout" do
      get :take_two
      response.should render_template(layout: false)
    end

    it "adds XML content-type to header" do
      get :take_two
      response.header["Content-Type"].should eq "text/xml"
    end

    it "selects the first two segments from the most recent Take Two episode" do
      get :take_two
      assigns(:segments).should_not be_blank
    end
  end
end
