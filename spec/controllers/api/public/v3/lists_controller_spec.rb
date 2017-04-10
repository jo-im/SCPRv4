require "spec_helper"

describe Api::Public::V3::ListsController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET index" do
    it "finds a live list" do
      list  = List.create title: "test-list", status: 5
      get :index, request_params
      assigns(:lists).should eq [list]
    end

    it "returns only lists that match the context query parameter" do
      list1  = List.create title: "test-list1", status: 5, context: "baz"
      list2  = List.create title: "test-list2", status: 5, context: "fubar"
      get :index, {context: "fubar"}.merge(request_params)
      assigns(:lists).should eq [list2]
    end
  end

  describe "GET list" do 
  end

end
