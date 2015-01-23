require 'spec_helper'

describe Concern::Controller::Searchable, type: :controller do
  controller(Outpost::ResourceController) do
    outpost_controller model: TestClass::Story
    include Concern::Controller::Searchable
  end

  before do
    routes.draw { get 'search' => "anonymous#search", as: :search }

    user = create :admin_user, is_superuser: true
    controller.stub(:current_user) { user }
  end


  it "adds a search action" do
    get :search
    response.should be_success
  end

  it "searches for the records" do
    article = create :test_class_story, body: "tinker tailor"

    get :search, query: "tinker tailor"

    assigns(:records).to_a.should eq [article]
  end
end
