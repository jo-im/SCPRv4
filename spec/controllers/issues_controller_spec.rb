require 'spec_helper'

describe IssuesController do
  render_views

  describe 'GET /issues' do
    it 'sets @issues to all active issues' do
      issues = create_list :issue, 3, :is_active
      inactive_issue = create :issue, :is_not_active

      get :index

      assigns(:issues).should eq issues.sort_by(&:title)
    end

    it "assigns popular articles" do
      article = create(:news_story).to_article
      Rails.cache.write("popular/viewed", [article])

      get :index
      assigns(:popular_articles).should eq [article]
    end
  end

  describe 'GET show' do
    it 'sets issues' do
      issue = create :issue, :is_active, slug: "whatever"
      get :show, slug: "whatever"
      assigns(:issues).should eq [issue]
    end

    it "gets the issue by slug" do
      issue = create :issue, :is_active, slug: "issue"
      get :show, slug: "issue"
      assigns(:issue).should eq issue
    end

    it "assigns popular articles" do
      article = create(:news_story).to_article
      Rails.cache.write("popular/viewed", [article])

      issue = create :issue, :is_active, slug: "okay"
      get :show, slug: "okay"
      assigns(:popular_articles).should eq [article]
    end

    it "raises an error if the slug isn't found" do
      -> {
        get :show, slug: "no"
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end
end
