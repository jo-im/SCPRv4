require 'spec_helper'

describe Feature do
  describe 'OPTIONS' do
    it "is an array of our Feature options" do
      Feature::OPTIONS.first.should be_a Feature
    end
  end

  describe '::find_by_id' do
    it 'retrieves the feature by a given ID' do
      Feature.find_by_id(1).should be_a Feature
    end

    it "is nil if no feature is found" do
      Feature.find_by_id(-200).should be_nil
    end
  end

  describe '::find_by_key' do
    it 'retrieves the feature by a given ID' do
      Feature.find_by_key(:test_feature).should be_a Feature
    end

    it "is nil if no feature is found" do
      Feature.find_by_key(:watwatwatwatwat).should be_nil
    end

  end

  describe 'attributes' do
    it "sets id" do
      Feature.new(id: 1).id.should eq 1
    end

    it "sets key" do
      Feature.new(key: :hello).key.should eq :hello
    end

    it "sets name" do
      Feature.new(name: "Hi").name.should eq "Hi"
    end

    it "sets asset display" do
      Feature.new(asset_display: "hidden").asset_display.should eq "hidden"
    end
  end
end
