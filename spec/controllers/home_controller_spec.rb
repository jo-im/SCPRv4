require "spec_helper"

describe HomeController do
  before(:all) do
    create :news_story
  end

  render_views

  describe 'GET /about_us' do
    it "is a success" do
      get :about_us
      response.should be_ok
    end
  end


  describe 'GET /index' do
    it "gets the homepage" do
      homepage = create :homepage, :published
      get :index
      assigns(:homepage).should eq homepage
    end

    it "only gets published homepages" do
      homepage = create :homepage, :pending
      get :index
      assigns(:homepage).should eq nil
    end

    it "gets the featured comment" do
      comment = create :featured_comment
      get :index
      assigns(:featured_comment).should eq comment
    end

    context "with a current schedule item" do
      let(:schedule_current) {
        create :schedule_occurrence,
          :starts_at => Time.zone.now - 1.hour,
          :ends_at   => Time.zone.now + 1.hour
      }

      it "gets the current schedule item" do
        schedule_current
        get :index
        assigns(:schedule_current).should eq schedule_current
      end

      it "gets the following schedule item" do
        schedule_next = create :schedule_occurrence,
          :starts_at => schedule_current.ends_at,
          :ends_at   => Time.zone.now + 4.hours

        get :index
        assigns(:schedule_next).should eq schedule_next
      end
    end

    context "without a current schedule item" do
      it "gets the next schedule item" do
        schedule_next = create :schedule_occurrence,
          :starts_at => 1.hour.from_now,
          :ends_at   => 4.hours.from_now

        get :index
        assigns(:schedule_current).present?.should eq false
        assigns(:schedule_next).should eq schedule_next
      end
    end
  end

end
