require "spec_helper"

describe Api::Public::V3::TagsController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET show" do
    it "finds the object if it exists" do
      tag = create :tag
      get :show, { id: tag.slug }.merge(request_params)
      assigns(:tag).should eq tag
      response.should render_template "show"
    end

    it "sets all the attributes" do
      tag = create :tag
      get :show, { id: tag.slug }.merge(request_params)

      json = JSON.parse(response.body)
      jtag = json["tag"]

      jtag["title"].should eq tag.title.as_json
      jtag["slug"].should eq tag.slug.as_json
    end

    it "returns a 404 status if it does not exist" do
      get :show, { id: "999" }.merge(request_params)
      response.response_code.should eq 404
      JSON.parse(response.body)["error"]["message"].should eq "Not Found"
    end
  end

  describe "GET index" do
    it "finds all tags" do
      tag = create :tag

      get :index, request_params
      JSON.parse(response.body)["tags"].first["title"].should eq tag.title.as_json
    end
  end
end
