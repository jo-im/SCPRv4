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

  describe 'GET search', :indexing do
    routes { Rails.application.routes }

    it 'gets the records from the query' do
      ns = create :news_story, headline: "Obama"
      be = create :blog_entry, headline: "President Obama"
      pq = create :pij_query, headline: "Something about Obama"

      get :search, gquery: "Obama"

      records = assigns(:records)

      obj_keys = records.map(&:obj_key)
      expect(obj_keys).to include ns.obj_key
      expect(obj_keys).to include be.obj_key
      expect(obj_keys).to include pq.obj_key
    end
  end
end
