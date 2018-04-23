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

    it "enforces ordering" do
      list1  = List.create title: "test-list1", status: 5, position: 2
      list2  = List.create title: "test-list2", status: 5, position: 1
      get :index, request_params
      assigns(:lists).should eq [list2, list1]
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
    it "orders items based on positions" do
      list  = List.create title: "test-list", status: 5
      story1 = create :news_story
      story2 = create :news_story
      list.items.create item_id: story1.id, item_type: story1.class.to_s, position: 2
      list.items.create item_id: story2.id, item_type: story2.class.to_s, position: 1
      get :show, {id: list.id}.merge(request_params)
      assigns(:list_items).should eq [story2.get_article, story1.get_article]
    end

    it "serves associated articles even if a category is associated" do
    end
    it "serves category items if there are no associated articles" do
    end
  end

end
