require "spec_helper"

describe Concern::Methods::StatusMethods do
  describe '::status_select_collection' do
    it 'is the statuses mapped to Array for a select collection' do
      TestClass::Story.status_select_collection.should be_a Array
      TestClass::Story.status_select_collection[0][0].should eq "Killed"
    end
  end

  describe '#status_type' do
    it "returns the status type" do
      story = build :test_class_story, :published
      story.status_type.should eq :published
    end
  end

  describe '#status_type_was' do
    it "is what the status type used to be" do
      story = create :test_class_story, :unpublished
      story.status = TestClass::Story.status_id(:live)
      story.status_type_was.should eq :unpublished
    end
  end

  describe '#status_is?' do
    it "returns true if the current status is the given key" do
      story = build :test_class_story, status: TestClass::Story.status_id(:draft)
      story.status_is?(:draft).should eq true
    end

    it "returns false if hte current status is not the given key" do
      story = build :test_class_story, status: TestClass::Story.status_id(:draft)
      story.status_is?(:live).should eq false
    end
  end

  describe '#status_was?' do
    it "returns true if the status was the given key" do
      story = create :test_class_story, status: TestClass::Story.status_id(:draft)
      story.status = TestClass::Story.status_id(:live)

      story.status_was?(:draft).should eq true
    end

    it "returns false if the status was not the given key" do
      story = create :test_class_story, status: TestClass::Story.status_id(:draft)
      story.status = TestClass::Story.status_id(:live)

      story.status_was?(:pending).should eq false
    end
  end

  describe '#status_type_is?' do
    it "returns true if the current status type is the given key" do
      story = build :test_class_story, :unpublished
      story.status_type_is?(:unpublished).should eq true
    end

    it "returns false if the current status type is not the given key" do
      story = build :test_class_story, :unpublished
      story.status_type_is?(:published).should eq false
    end
  end

  describe '#status_type_was?' do
    it "returns true if the status type was the given key" do
      story = create :test_class_story, :unpublished
      story.status = TestClass::Story.status_id(:live)

      story.status_type_was?(:unpublished).should eq true
    end

    it "returns false if the status type was not the given key" do
      story = create :test_class_story, :unpublished
      story.status = TestClass::Story.status_id(:live)

      story.status_type_was?(:pending).should eq false
    end
  end

  describe '#unpublished?' do
    it "is true if the current status type is unpublished type" do
      story = build :test_class_story, :unpublished
      story.unpublished?.should eq true
    end
  end

  describe '#pending?' do
    it "is true if the current status type is pending type" do
      story = build :test_class_story, :pending
      story.pending?.should eq true
    end
  end

  describe '#published?' do
    it "is true if the current status type is published type" do
      story = build :test_class_story, :published
      story.published?.should eq true
    end
  end

  describe "#publishing?" do
    it "is true if status was changed unpublished -> published" do
      story = create :test_class_story, :pending
      story.publishing?.should eq false

      story.status = story.class.status_id(:live)
      story.publishing?.should eq true
    end

    it "is false if status was not changed" do
      story = create :test_class_story, :published
      story.status = story.class.status_id(:live)
      story.publishing?.should eq false
    end

    it "is false if status was changed published -> unpublished" do
      story = create :test_class_story, :published
      story.status = story.class.status_id(:draft)
      story.publishing?.should eq false
    end

    it "is false if the status was changed unpublished -> unpublished" do
      story = create :test_class_story, :draft
      story.status = story.class.status_id(:pending)
      story.publishing?.should eq false
    end

    it "is false if the status was changed published -> published" do
      story = create :test_class_story, :published
      story.status = story.class.status_id(:published)
      story.publishing?.should eq false
    end
  end

  describe "#unpublishing?" do
    it "is true if status was changed published -> unpublished" do
      story = create :test_class_story, :published
      story.unpublishing?.should eq false

      story.status = story.class.status_id(:draft)
      story.unpublishing?.should eq true
    end

    it "is false if status was not changed" do
      story = create :test_class_story, :draft
      story.status = story.class.status_id(:draft)
      story.unpublishing?.should eq false
    end

    it "is false if status was changed unpublished -> published" do
      story = create :test_class_story, :draft
      story.status = story.class.status_id(:live)
      story.unpublishing?.should eq false
    end

    it "is false when going pending -> published" do
      story = create :test_class_story, :pending
      story.status = story.class.status_id(:live)
      story.unpublishing?.should eq false
    end

    it "is true when going published -> pending" do
      story = create :test_class_story, :published
      story.status = story.class.status_id(:pending)
      story.unpublishing?.should eq true
    end

    it "is false if status was changed from unpublished -> unpublished" do
      story = create :test_class_story, :draft
      story.status = story.class.status_id(:pending)
      story.unpublishing?.should eq false
    end
  end

  describe '#status_text' do
    it 'returns the human-friendly status' do
      story = build :test_class_story, status: TestClass::Story.status_id(:live)
      story.status_text.should eq "Published"
    end
  end
end
