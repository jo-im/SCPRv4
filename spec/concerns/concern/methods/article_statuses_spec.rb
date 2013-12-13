require 'spec_helper'

describe Concern::Methods::ArticleStatuses do
  describe 'setting statuses' do
    let(:story) { build :test_class_story }

    it "has killed status" do
      story.status = TestClass::Story.status_id(:killed)
      story.status.should eq -1
    end

    it "has draft status" do
      story.status = TestClass::Story.status_id(:draft)
      story.status.should eq 0
    end

    it "has awaiting_rework status" do
      story.status = TestClass::Story.status_id(:awaiting_rework)
      story.status.should eq 1
    end

    it "has awaiting_edit status" do
      story.status = TestClass::Story.status_id(:awaiting_edits)
      story.status.should eq 2
    end

    it "has pending status" do
      story.status = TestClass::Story.status_id(:pending)
      story.status.should eq 3
    end

    it "has live status" do
      story.status = TestClass::Story.status_id(:live)
      story.status.should eq 5
    end
  end

  describe 'publish' do
    it 'sets the status to live' do
      story = build :test_class_story, :unpublished
      story.save!
      story.published?.should eq false

      story.publish
      story.reload.published?.should eq true
    end
  end
end
