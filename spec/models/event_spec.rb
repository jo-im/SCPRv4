require "spec_helper"

describe Event do
  describe "::sorted" do
    let(:past_one     ) { build :event, starts_at: 2.hours.ago,      ends_at: 1.hour.ago }
    let(:past_many    ) { build :event, starts_at: 3.days.ago,       ends_at: 1.day.ago }
    let(:current_one  ) { build :event, starts_at: 1.hour.ago,       ends_at: 1.hour.from_now }
    let(:current_many ) { build :event, starts_at: 1.day.ago,        ends_at: 1.day.from_now }
    let(:future_one   ) { build :event, starts_at: 1.hour.from_now,  ends_at: 2.hours.from_now }
    let(:future_many  ) { build :event, starts_at: 2.days.from_now,  ends_at: 4.days.from_now }

    let(:events) { [past_one, past_many, current_one, current_many, future_one, future_many].shuffle }

    before :each do
      t = Time.zone.now.beginning_of_day + 12.hours
      Time.stub(:now) { t } # noon
    end

    context "ascending" do
      # Is there a more reliable way to test this?
      it "sorts based on instance sorter" do
        Event.sorted(events, :asc).should eq [past_many, past_one, current_one, future_one, current_many, future_many]
      end
    end

    context "descending" do
      it "sorts based on instance order" do
        past_one      = build :event, starts_at: 2.hours.ago,      ends_at: 1.hour.ago
        past_many     = build :event, starts_at: 3.days.ago,       ends_at: 1.day.ago
        current_one   = build :event, starts_at: 1.hour.ago,       ends_at: 1.hour.from_now
        current_many  = build :event, starts_at: 1.day.ago,        ends_at: 1.day.from_now
        future_one    = build :event, starts_at: 1.hour.from_now,  ends_at: 2.hours.from_now
        future_many   = build :event, starts_at: 2.days.from_now,  ends_at: 4.days.from_now

        events = [past_one, past_many, current_one, current_many, future_one, future_many].shuffle
        Event.sorted(events).should eq [past_many, past_one, current_one, future_one, current_many, future_many]
      end
    end
  end

  #-------------------

  describe "#sorter" do
    before :each do
      t = Time.zone.now.beginning_of_day + 12.hours
      Time.stub(:now) { t } # noon
    end

    it "returns the event's ends_at if it's multiple days and current" do
      event = build :event, :multiple_days_current
      event.sorter.should eq event.ends_at
    end

    it "returns the event's starts_at if it's < 24 hours" do
      event = build :event, :current
      event.sorter.should eq event.starts_at
    end

    it "returns the event's starts_at if it's multiple days in the future" do
      event = build :event, :multiple_days_future
      event.sorter.should eq event.starts_at
    end

    it "returns the event's starts_at if it's multiple days in the past" do
      event = build :event, :multiple_days_past
      event.sorter.should eq event.starts_at
    end
  end

  #-------------------

  describe "#multiple_days?" do
    it "is true if > 24 hours" do
      event = Event.new
      event.stub(:minutes) { 60*48 }
      event.multiple_days?.should eq true
    end

    it "is false if < 24 hours" do
      event = Event.new
      event.stub(:minutes) { 60*12 }
      event.multiple_days?.should eq false
    end

    it "is false if == 24 hours" do
      event = Event.new
      event.stub(:minutes) { 60*24 }
      event.multiple_days?.should eq false
    end
  end

  #-------------------

  describe "#minutes" do
    it "calculates the minutes of the event" do
      event = build :event, starts_at: 2.minutes.ago, ends_at: 3.minutes.from_now
      event.minutes.should be_a Fixnum
      event.minutes.should eq 5
    end
  end

  #-------------------

  describe "#ongoing?" do
    it "is true if multiple day and current" do
      event = Event.new
      event.stub(:multiple_days?) { true }
      event.stub(:current?) { true }
      event.ongoing?.should eq true
    end
  end

  #-------------------

  describe "#upcoming?" do
    it "is true if the start time is greater than right now" do
      event = build :event, ends_at: nil, starts_at: 1.hour.from_now
      event.upcoming?.should eq true
    end

    it "is false if the event start time is in the past" do
      event = build :event, ends_at: nil, starts_at: 1.hour.ago
      event.upcoming?.should eq false
    end
  end

  #-------------------

  describe "#current?" do
    before :each do
      t = Time.zone.now.beginning_of_day + 12.hours
      Time.stub(:now) { t } # noon
    end

    it "is true if Time.zone.now is between the start and end times" do
      event = build :event, :current
      event.current?.should eq true
    end

    it "is true if ends_at is blank and Time.zone.now is between start time and end of day" do
      event = build :event, starts_at: 1.hour.ago, ends_at: nil
      event.current?.should eq true
    end

    it "is false if start time is in the future" do
      event = build :event, :future
      event.current?.should eq false
    end

    it "is false if event ends_at is in the past" do
      event = build :event, :past
      event.current?.should eq false
    end

    it "is false if no ends_at and event starts_at was yeserday" do
      event = build :event, starts_at: Time.zone.now.yesterday
      event.current?.should eq false
    end
  end

  #-------------------

  describe "::closest" do # TODO All the scopes are ugly and inefficient
    it "returns the closest published future event" do
      events  = create_list :event, 5, :published
      closest = Event.closest
      closest.should eq Event.upcoming.first
      closest.should eq events.first
    end
  end

  #-------------------

  describe "scopes" do
    describe "published" do
      it "only selects published content" do
        published   = create :event, :published
        unpublished = create :event, :unpublished
        Event.published.should eq [published]
      end
    end

    describe "upcoming" do
      it "only selects future events" do
        past_event   = create :event, :published, :past
        future_event = create :event, :published, :future
        Event.upcoming.should eq [future_event]
      end
    end

    describe "upcoming_and_current" do
      it "selects event that are future or currently happening" do
        past_event    = create :event, :published, :past
        current_event = create :event, :published, :current
        future_event  = create :event, :published, :future, ends_at: nil
        Event.upcoming_and_current.should eq [current_event, future_event]
      end

      it "orders by starts_at" do
        Event.upcoming_and_current.to_sql.should match /order by starts_at/i
      end
    end

    describe "past" do
      it "only selects past events" do
        past_event   = create :event, :published, :past
        future_event = create :event, :published, :future
        Event.past.should eq [past_event]
      end

      it "does not include current events" do
        past_event   = create :event, :published, :past
        future_event = create :event, :published, :future
        Event.past.should eq [past_event]
      end
    end

    describe "forum" do
      it "only selects events of types in ForumTypes array" do
        spon_event   = create :event, :published, event_type: "spon" # "spon" = sponsored
        pick_event   = create :event, :published, event_type: "pick"
        comm_event   = create :event, :published, event_type: "comm"
        forum_events = Event.forum
        forum_events.should eq [comm_event]
      end
    end

    describe "sponsored" do
      it "only selects events of type 'spon'" do
        spon_event  = create :event, :published, event_type: "spon"
        pick_event  = create :event, :published, event_type: "pick"
        comm_event  = create :event, :published, event_type: "comm"
        spon_events = Event.sponsored
        spon_events.should eq [spon_event]
      end
    end
  end

  #-------------------

  describe "#is_forum_event" do
    it "is true if event type in the ForumTypes variable" do
      Event::ForumTypes.each do |event_type|
        event = build :event, event_type: event_type
        event.is_forum_event?.should eq true
      end
    end

    it "is false if event is something else" do
      event = build :event, event_type: "spon"
      event.is_forum_event?.should eq false
    end
  end

  describe '#to_article' do
    it "turns the event into an article" do
      event = build :event
      event.to_article.should be_a Article
    end
  end

  describe "url sanitization" do
    context "before validation" do 
      it "removes trailing whitespaces from url attributes" do
        event = build :event, sponsor_url: " http://someurl.com/ ", location_url: " http://someurl.com/ ", rsvp_url: " http://someurl.com/ "
        event.valid?
        expect(event.sponsor_url).to eq "http://someurl.com/"
        expect(event.location_url).to eq "http://someurl.com/"
        expect(event.rsvp_url).to eq "http://someurl.com/"
      end
    end
  end
end
