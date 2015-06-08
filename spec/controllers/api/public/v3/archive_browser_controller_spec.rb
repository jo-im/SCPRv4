require "spec_helper"

describe Api::Public::V3::ArchiveBrowserController do
  request_params = {
    :format => :json
  }

  render_views

  describe "GET index" do
    it "finds the object if it exists" do
      program = create :kpcc_program, slug: "test-program"
      old_episode = create :show_episode, show: program, air_date: Date.parse("2015-01-15")
      new_episode = create :show_episode, show: program, air_date: Date.parse("2015-02-15")
      get :index, { id: "test-program", year: '2015', month: '2' }.merge(request_params)
      assigns(:episodes).should eq [new_episode]
    end
    it "returns only published episodes" do
      program = create :kpcc_program, slug: "test-program"
      published = create :show_episode, :published, air_date: Date.parse("2015-02-15"), show: program
      unpublished = create :show_episode, :draft, air_date: Date.parse("2015-02-15"), show: program
      get :index, { id: 'test-program', year: "2015", month: "2" }.merge(request_params)
      assigns(:episodes).should_not include(unpublished)
      assigns(:episodes).should include(published)
    end
    it "returns a 404 status if it does not exist" do
      get :index, { id: 'nonexistant_program', year: "2015", month: "2" }.merge(request_params)
      response.response_code.should eq 404
      JSON.parse(response.body)["error"]["message"].should eq "Program not found. (nonexistant_program)"
    end
  end
end
