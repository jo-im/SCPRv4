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

    it "ignores lists that are drafts" do
      list  = List.create title: "test-list", status: 1
      get :index, request_params
      assigns(:lists).should eq []
    end

  end

  describe "GET list" do 
    it "finds a list and its associated articles" do
      list  = List.create title: "test-list", status: 5
      story = create :news_story 
      list.items.create item_id: story.id, item_type: story.class.to_s
      get :show, {id: list.id}.merge(request_params)
      assigns(:list).should eq list
      assigns(:list_items).should eq [story.get_article]
    end
  end

end
