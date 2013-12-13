require "spec_helper"

describe Concern::Callbacks::SetPublishedAtCallback do
  let(:story) { build :test_class_story }

  #-----------------

  describe "#should_set_published_at_to_now?" do
    it "is true if the object is published but doesn't have a published_at date" do
      story.status = story.class.status_id(:live)
      story.published_at = nil
      story.should_set_published_at_to_now?.should eq true
    end

    it "is false if not published" do
      story.status = story.class.status_id(:draft)
      story.should_set_published_at_to_now?.should eq false
    end

    it "is false if published_at is present" do
      story.status = story.class.status_id(:live)
      story.published_at = Time.now
      story.should_set_published_at_to_now?.should eq false
    end
  end

  #-----------------

  describe "#set_published_at_to_now" do
    context "should_set_published_at_to_now is true" do
      before :each do
        story.stub(:should_set_published_at_to_now?) { true }
      end

      it "sets published at to now" do
        t = Time.now
        Time.stub(:now) { t }

        story.save!
        story.published_at.should eq t
      end
    end

    context "should_set_published_at_to_now is false" do
      before :each do
        story.stub(:should_set_published_at_to_now?) { false }
        story.status = story.class.status_id(:draft)
      end

      it "does not set published at to now" do
        t = Time.now
        Time.stub(:now) { t }

        story.save!
        story.published_at.should be_nil
      end
    end
  end

  #-----------------

  describe "#should_set_published_at_to_nil?" do
    it "is true if the object is not published and the published_at date is set" do
      story.status = story.class.status_id(:draft)
      story.published_at = Time.now
      story.should_set_published_at_to_nil?.should eq true
    end

    it "is false if object is published" do
      story.published_at = Time.now
      story.should_set_published_at_to_nil?.should eq false
    end
  end

  #-----------------

  describe "#set_published_at_to_nil" do
    context "should_set_published_at_to_nil? is true" do
      before :each do
        story.published_at = Time.now - 1.hour
        story.status = story.class.status_id(:draft)
        story.stub(:should_set_published_at_to_nil?) { true }
        story.published_at.should_not be_nil
        story.save!
      end

      it "sets published_at to nil" do
        story.published_at.should eq nil
      end
    end

    context "should_set_published_at_to_nil? is false" do
      before :each do
        story.published_at = Time.now
        story.stub(:should_set_published_at_to_nil?) { false }
        story.published_at.should_not be_nil
        story.save!
      end

      it "does not set published_at to nil" do
        story.published_at.should_not be_nil
      end
    end
  end
end
