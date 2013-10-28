require "spec_helper"

describe PressReleasesController do
  describe "GET /index" do
    it "assigns @press_releases to all press releases" do
      release = create :press_release
      get :index
      assigns(:press_releases).should eq [release]
    end

    it 'orders by created_at desc' do
      release1 = create :press_release
      release2 = create :press_release

      release1.update_column(:created_at, 1.week.ago)

      get :index
      assigns(:press_releases).should eq [release2, release1]
    end
  end

  #-------------

  describe "GET /show" do
    it "gets the requested press release" do
      release = create :press_release, slug: "wat"
      get :show, slug: release.slug
      assigns(:press_release).should eq release
    end

    it "raises a RecordNotFound if slug doesn't exist" do
      -> {
        get :show, slug: "nope"
      }.should raise_error ActiveRecord::RecordNotFound
    end
  end
end
