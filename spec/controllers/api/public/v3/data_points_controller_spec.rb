require "spec_helper"

describe Api::Public::V3::DataPointsController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET show" do
    it "finds the object if it exists" do
      data_point = create :data_point
      get :show, { id: data_point.data_key }.merge(request_params)
      assigns(:data_point).should eq data_point
      response.should render_template "show"
    end

    it "includes the correct attributes" do
      data_point = create :data_point,
        :title => "Data Point",
        :group_name => "Group Name",
        :data_key => "Data Key",
        :data_value => "Data Value",
        :notes => "Notes"

      get :show, { id: data_point.data_key }.merge(request_params)

      json = JSON.parse(response.body)
      dp = json["data_point"]

      dp["title"].should eq data_point.title.as_json
      dp["group"].should eq data_point.group_name.as_json
      dp["key"].should eq data_point.data_key.as_json
      dp["value"].should eq data_point.data_value.as_json
      dp["notes"].should eq data_point.notes.as_json
      dp["updated_at"].should eq data_point.updated_at.as_json
    end

    it "returns a 404 status if it does not exist" do
      get :show, { id: "nope" }.merge(request_params)
      response.response_code.should eq 404
      response.body.should eq Hash[error: "Not Found"].to_json
    end
  end

  describe "GET index" do
    it "orders by updated_at desc" do
      get :index, request_params
      assigns(:data_points).to_sql.should match /updated_at desc/
    end

    it "can filter by group" do
      dp1 = create :data_point, group_name: "group1"
      dp2 = create :data_point, group_name: "group2"

      get :index, { group: "group1" }.merge(request_params)

      assigns(:data_points).to_a.should eq [dp1]
    end

    it "accepts a response_format" do
      get :index, { response_format: "simple" }.merge(request_params)
      assigns(:response_format).should eq "simple"

      get :index, { response_format: "full" }.merge(request_params)
      assigns(:response_format).should eq "full"
    end

    it "sanitizes the response_format as sets full as default" do
      get :index, { response_format: "nope" }.merge(request_params)
      assigns(:response_format).should eq "full"
    end

    context "simple format" do
      it "returns a simple key-value format" do
        dp1 = create :data_point, data_key: "key1", data_value: "value1"
        dp2 = create :data_point, data_key: "key2", data_value: "value2"

        get :index, { response_format: "simple" }.merge(request_params)
        json = JSON.parse(response.body)

        json["data_points"]["key1"].should eq "value1"
        json["data_points"]["key2"].should eq "value2"
      end
    end

    context "full format" do
      it "returns the full JSON objects" do
        dp1 = create :data_point, data_key: "key1", data_value: "value1"
        dp2 = create :data_point, data_key: "key2", data_value: "value2"

        get :index, { response_format: "full" }.merge(request_params)
        json = JSON.parse(response.body)
        json["data_points"].should be_a Array # meh
      end
    end
  end
end
