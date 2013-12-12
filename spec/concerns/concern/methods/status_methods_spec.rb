require "spec_helper"
__END__
describe Concern::Methods::ContentStatusMethods do
  describe "#pending?" do
    it "is true if status is ContentBase::STATUS_PENDING" do
      story = build :test_class_story, status: ContentBase::STATUS_PENDING
      story.pending?.should eq true
    end

    it "is false if status is not ContentBase::STATUS_PENDING" do
      story = build :test_class_story, status: ContentBase::STATUS_LIVE
      story.pending?.should eq false
    end
  end

  #------------------------

  describe "#published?" do
    it "is true if status is ContentBase::STATUS_LIVE" do
      story = build :test_class_story, status: ContentBase::STATUS_LIVE
      story.published?.should eq true
    end

    it "is false if status is not ContentBase::STATUS_LIVE" do
      story = build :test_class_story, status: ContentBase::STATUS_KILLED
      story.published?.should eq false
    end
  end

  describe '#status_text' do
    it 'returns the human-friendly status' do
      story = build :test_class_story, status: ContentBase::STATUS_LIVE
      story.status_text.should_not eq nil
    end
  end

  describe 'publish' do
    it 'sets the status to STATUS_LIVE' do
      story = build :test_class_story, status: ContentBase::STATUS_DRAFT
      story.save!
      story.published?.should eq false

      story.publish
      story.reload.published?.should eq true
    end
  end
end

describe Concern::Methods::StatusMethods do
  describe "#publishing?" do
    it "is true if status was changed and object is published" do
      story = create :test_class_story, :pending
      story.publishing?.should eq false

      story.status = ContentBase::STATUS_LIVE
      story.publishing?.should eq true
    end

    it "is false if status was not changed" do
      story = create :test_class_story, :published
      story.status = ContentBase::STATUS_LIVE
      story.publishing?.should eq false
    end

    it "is false if status was changed to something non-published" do
      story = create :test_class_story, :published
      story.status = ContentBase::STATUS_DRAFT
      story.publishing?.should eq false
    end
  end

  #--------------------

  describe "#unpublishing?" do
    it "is true if status was changed and object is not published" do
      story = create :test_class_story, :published
      story.unpublishing?.should eq false

      story.status = ContentBase::STATUS_DRAFT
      story.unpublishing?.should eq true
    end

    it "is false if status was not changed" do
      story = create :test_class_story, :draft
      story.status = ContentBase::STATUS_DRAFT
      story.unpublishing?.should eq false
    end

    it "is false if status was changed to published" do
      story = create :test_class_story, :draft
      story.status = ContentBase::STATUS_LIVE
      story.unpublishing?.should eq false
    end

    it "is false if status was changed from unpublished -> unpublished" do
      story = create :test_class_story, :draft
      story.status = ContentBase::STATUS_PENDING
      story.unpublishing?.should eq false
    end
  end
end
