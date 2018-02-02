require "spec_helper"

describe UpcomingEventsListCell do
  describe "GET" do
    before :each do
      # Create a list of current and upcoming events and feed it into a cell instance
      current_event = create :event, :published, starts_at: 2.hours.ago, ends_at: 2.hours.from_now, event_type: 'comm', headline: 'Public Media Potluck'
      future_event  = create :event, :published, starts_at: 2.hours.from_now, ends_at: 3.hours.from_now, event_type: 'comm', headline: 'Blood Moon'
      upcoming_events_list = [current_event, future_event]
      @cell_instance = cell(:upcoming_events_list, upcoming_events_list)
    end
    
    it "renders upcoming events" do
      expect(@cell_instance.call).to include 'Public Media Potluck'
      expect(@cell_instance.call).to include 'Blood Moon'
    end
    
    it "renders asset with default gravity if no image_gravity is given" do
      # Defaults to asset fallback (absent of image_gravity) when no asset is attached
      test_event = create :event, :published, starts_at: 2.hours.ago, ends_at: 2.hours.from_now, event_type: 'comm'
      
      expect(@cell_instance.call(:asset_position, test_event)).to eq 'center'
    end
    
    it "renders asset with specified gravity if image_gravity is given" do
      asset = create :asset
      test_event = create :event, :published, starts_at: 2.hours.ago, ends_at: 2.hours.from_now, event_type: 'comm'
      test_event.assets << asset
      test_event.save!

      expect(@cell_instance.call(:asset_position, test_event)).to eq 'Left'
    end
  end
end