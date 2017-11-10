require "spec_helper"

describe EventsController do
  describe "GET /kpcc_in_person" do
    describe "view" do
      render_views

      it "renders the view" do
        get :kpcc_in_person
      end
    end

    describe "controller" do
      it "assigns @upcoming_events using upcoming_and_current scope" do
        past_event    = create :event, :published, starts_at: 2.hours.ago, ends_at: 1.hour.ago, event_type: 'comm'
        current_event = create :event, :published, starts_at: 2.hours.ago, ends_at: 2.hours.from_now, event_type: 'comm'
        future_event  = create :event, :published, starts_at: 2.hours.from_now, ends_at: 3.hours.from_now, event_type: 'comm'
        get :kpcc_in_person
        assigns(:all_upcoming_events).should eq [current_event, future_event]
      end
    end
  end

  #-----------------

  describe "GET /show" do
    describe "view" do
      render_views

      it "renders the view" do
        event = create :event, :published
        get :show, event.route_hash
      end
    end

    describe "controller" do
      it "gets the event from the URL params" do
        event = create :event, :published
        get :show, event.route_hash
        assigns(:event).should eq event
      end

      it "assigns more events to other future forum events" do
        event    = create :event, :published
        upcoming = create_list :event, 2, :future, :published
        get :show, event.route_hash
        assigns(:more_events).sort.should eq upcoming.sort
      end

      it "only finds published events" do
        event = create :event, status: 0
        -> { get :show, event.route_hash }.should raise_error ActionController::UrlGenerationError
      end
    end
  end

  #-----------------------

  describe "GET /archive" do
    describe "view" do
      render_views

      it "renders the view" do
        get :archive
      end
    end

    describe "controller" do
      it "gets the past forum events" do
        past_events   = create_list :event, 2, :past, :published
        future_events = create :event, :future, :published
        get :archive
        assigns(:events).sort.should eq past_events.sort
      end

      it "paginates" do
        past_events = create_list :event, 12, :past, :published
        get :archive, page: 2
        assigns(:events).size.should eq 2
      end
    end
  end
end
