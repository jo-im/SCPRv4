require 'spec_helper'

describe Concern::Controller::GetPopularArticles, type: :controller do
  controller(ApplicationController) do
    include Concern::Controller::GetPopularArticles
    before_filter :get_popular_articles

    def index
      render nothing: true
    end
  end

  it "gets the popular articles" do
    article = create :test_class_story
    Rails.cache.write('popular/viewed', [article])

    get :index
    assigns(:popular_articles).should eq [article]
  end
end
