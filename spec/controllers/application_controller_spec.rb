require "spec_helper"

# Test against HomeController so we can call an action
describe HomeController do
  it "sets upcoming forum events" do
    event = create :event, :published, :future, event_type: "comm"
    get :index
    assigns(:upcoming_events_forum).should eq [event]
  end

  it "sets upcoming sponsored events" do
    event = create :event, :published, :future, event_type: "spon"
    get :index
    assigns(:upcoming_events_sponsored).should eq [event]
  end

  it "sets latest news blogs" do
    blog = create :blog
    entry = create :blog_entry, :published, blog: blog
    get :index
    assigns(:latest_blogs).should eq [entry]
  end
end
