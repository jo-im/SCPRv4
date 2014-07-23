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

    describe "with cache available" do
      it "short-circuits and returns cache" do
        cache_value = "Cache hit."
        Rails.cache.should_receive(:fetch).with("feeds:all_news").and_return(cache_value)
        get :all_news
        response.body.should eq cache_value
      end
    end

    describe "without cache available" do
      it "returns a string" do
        get :all_news
        response.body.should be_a String
      end

      it "writes to cache" do
        Rails.cache.should_receive(:write_entry)
        get :all_news
      end

      it "uses sphinx to populate @content" do
        get :all_news
        assigns(:content).should_not be_blank
      end
    end
  end

  describe "GET /take_two" do
    before :each do
      take_two = create :kpcc_program, :segmented, slug: 'take-two'
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
