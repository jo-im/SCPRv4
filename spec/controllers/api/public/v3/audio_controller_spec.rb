require "spec_helper"

describe Api::Public::V3::AudioController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET show" do
    it "finds the object if it exists" do
      audio = create :audio, :uploaded
      get :show, { id: audio.id }.merge(request_params)
      assigns(:audio).should eq audio
      response.should render_template "show"

      purge_uploaded_audio
    end

    it "returns a 404 status if it does not exist" do
      get :show, { id: "99" }.merge(request_params)
      response.response_code.should eq 404
      JSON.parse(response.body)["error"]["message"].should eq "Not Found"
    end

    context "kpcc episode" do
      it "gives a via param" do
        episode = create :show_episode
        audio = create(:audio, :uploaded, {
          created_at: Time.zone.now,
          mp3: load_audio_fixture("point1sec-#{3}.mp3"),
          content_id: episode.id,
          content_type: episode.class.to_s,
          size: 0,
          description: "test description",
          byline: "",
          duration: 300
        })
        get :show, { id: audio.id }.merge(request_params)
        JSON.parse(response.body)["audio"]["url"].should include("via=")
      end
    end

    context "external episode" do
      it "omits a via param" do
        episode = create :external_episode
        audio = create(:audio, :external, {
          created_at: Time.zone.now,
          content_id: episode.id,
          content_type: episode.class.to_s,
          size: 0,
          description: "test description",
          byline: "",
          duration: 300
        })
        get :show, { id: audio.id }.merge(request_params)
        JSON.parse(response.body)["audio"]["url"].should_not include("via=")
      end
    end

  end


  describe "GET index" do
    before :each do
      @available   = []

      3.times do |n|
        @available << create(:audio, :uploaded,
          created_at: Time.zone.now + n.minutes,
          mp3: load_audio_fixture("point1sec-#{n}.mp3")
        )
      end

      @unavailable = create_list :audio, 2, :enco
    end

    after :each do
      purge_uploaded_audio
    end

    it "sanitizes the limit" do
      get :index, { limit: "Evil Code" }.merge(request_params)
      assigns(:limit).should eq 0
      assigns(:audio).should eq @available.sort_by(&:created_at).reverse
    end

    it "accepts a limit" do
      get :index, { limit: 1 }.merge(request_params)
      assigns(:audio).size.should eq 1
    end

    it "sets the max limit to 40" do
        get :index, { limit: 100 }.merge(request_params)
        assigns(:limit).should eq 40
    end

    it "sanitizes the page" do
      get :index, { page: "Evil Code" }.merge(request_params)
      assigns(:page).should eq 1
      assigns(:audio).size.should eq @available.size
    end

    it "accepts a page" do
      get :index, request_params
      third_obj = assigns(:audio)[2]

      get :index, { page: 3, limit: 1 }.merge(request_params)
      assigns(:audio).should eq [third_obj]
    end

    it "only gets available audio" do
      get :index, request_params
      (assigns(:audio) & @unavailable).should eq []
    end
  end
end
