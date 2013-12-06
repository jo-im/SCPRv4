require 'spec_helper'

describe Concern::Methods::AssetDisplayMethods do
  describe '::select_collection' do
    it "is an array of asset displays" do
      Concern::Methods::AssetDisplayMethods.select_collection
        .should be_a Array
    end
  end

  describe '#asset_display' do
    it 'gets the asset display for the object' do
      story = build :test_class_story, asset_display_id: 1
      story.asset_display.should eq :slideshow
    end

    it "is nil if there is no asset_display_id" do
      story = build :test_class_story, asset_display_id: nil
      story.asset_display_id.should eq nil
    end
  end

  describe '#asset_display=' do
    it "sets the asset_display_id" do
      story = build :test_class_story, asset_display_id: nil
      story.asset_display = :slideshow
      story.asset_display_id.should eq 1
    end

    it "sets asset_display_id to nil if nil is passed in" do
      story = build :test_class_story, asset_display_id: nil
      story.asset_display = nil
      story.asset_display_id.should eq nil

    end
  end
end
