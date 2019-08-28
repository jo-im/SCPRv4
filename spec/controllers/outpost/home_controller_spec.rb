require "spec_helper"

describe Outpost::HomeController do
  render_views

  before do
    @current_user = create :admin_user
    controller.stub(:current_user) { @current_user }
  end

  describe 'GET dashboard' do
    routes { Outpost::Engine.routes }

    it 'gets the current user activities' do
      story = create :news_story, logged_user_id: @current_user.id

      get :dashboard
      assigns(:current_user_activities).should eq story.versions.to_a
    end

    it 'gets the latest activities from any user' do
      other_user = create :admin_user

      story1 = create :news_story, logged_user_id: @current_user.id
      story2 = create :news_story, logged_user_id: other_user.id

      get :dashboard
      assigns(:latest_activities).should eq story2.versions.to_a
    end
  end
end
