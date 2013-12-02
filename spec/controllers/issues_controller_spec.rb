require 'spec_helper'

describe IssuesController do
  render_views

  describe 'GET /issues' do
    it 'sets @issues to all active issues' do
      issues = create_list :issue, 3, :is_active
      inactive_issue = create :issue, :is_not_active
      get :index
      assigns(:issues).should eq issues
      assigns(:issues).count.should eq 3
      assigns(:issues).should_not include(inactive_issue)
    end
  end
end
