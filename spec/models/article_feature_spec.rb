require 'spec_helper'

describe ArticleFeature do
  describe '::find_by_id' do
    it 'retrieves the feature by a given ID' do
      ArticleFeature.find_by_id(1).key.should eq :slideshow
    end

    it "is nil if no feature is found" do
      ArticleFeature.find_by_id(-200).should be_nil
    end
  end

  describe '::find_by_key' do
    it 'retrieves the feature by a given key' do
      ArticleFeature.find_by_key(:slideshow).id.should eq 1
    end

    it "is nil if no feature is found" do
      ArticleFeature.find_by_key(:watwatwatwatwat).should be_nil
    end
  end

  describe 'attributes' do
    it "sets id" do
      ArticleFeature.new(id: 1, key: :lasagna).id.should eq 1
    end

    it "sets key" do
      ArticleFeature.new(key: :hello).key.should eq :hello
    end

    it "sets name" do
      ArticleFeature.new(name: "Hi", key: :lasagna).name.should eq "Hi"
    end

    it "sets asset display" do
      ArticleFeature.new(asset_display: "hidden", key: :lasagna)
        .asset_display.should eq "hidden"
    end
  end

  describe '#==' do
    it "compares integers" do
      feature = ArticleFeature.new(id: 123, key: :lasagna)
      (feature == 123).should eq true
    end

    it "compares article features" do
      feature = ArticleFeature.new(id: 456, key: :lasagna)
      (feature == feature).should eq true
    end

    it "compares keys" do
      feature = ArticleFeature.new(key: :yo)
      (feature == :yo).should eq true
    end
  end
end
