require "spec_helper"

describe Outpost::VersionsController do
  render_views

  before :each do
    @user = create :admin_user
    permissions = Permission.where(resource: ["BlogEntry", "NewsStory"])
    @user.permissions = permissions
    controller.stub(:current_user) { @user }
  end

  describe "GET /activity" do
    it "lists all recent activity" do
      story1 = create :news_story
      story2 = create :news_story
      story3 = create :blog_entry

      get :activity
      versions = assigns(:versions)

      versions.should include story3.versions.first
      versions.should include story2.versions.first
      versions.should include story1.versions.first
    end
  end

  #-------------------

  describe "GET /index" do
    it "lists activity for a record" do
      story1 = create :news_story
      story2 = create :news_story

      get :index, resources: "news_stories", resource_id: story1.id
      assigns(:versions).should eq story1.versions.to_a
    end
  end

  #-------------------

  describe "GET /show" do
    it "gets the requested version" do
      story = create :news_story

      get :show, {
        :resources        => "news_stories",
        :resource_id      => story.id,
        :version_number   => 1
      }

      assigns(:version).should eq story.versions.first
    end
  end
end
