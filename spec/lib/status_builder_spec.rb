require 'spec_helper'

describe StatusBuilder do
  describe '::has_status' do
    it "loads the status methods for the class" do
      TestClass::PublishableEntity.should respond_to :statuses
    end
  end

  describe '::statuses' do
    it 'is an array' do
      TestClass::PublishableEntity.statuses.should be_a Array
    end
  end

  describe '::status_ids' do
    it "returns an array of ids for the given key" do
      TestClass::PublishableEntity.status_ids(:draft, :published)
        .should eq [0, 2]
    end

    it "ignores unrecognized keys" do
      TestClass::PublishableEntity.status_ids(:nope).should eq []
    end
  end

  describe '::status_id' do
    it "returns the status id of the given key" do
      TestClass::PublishableEntity.status_id(:draft).should eq 0
    end

    it "returns nil if the key isn't recognized" do
      TestClass::PublishableEntity.status_id(:nope).should eq nil
    end
  end

  describe '::find_status_by_id' do
    it 'returns the status by its id' do
      TestClass::PublishableEntity.find_status_by_id(0).key.should eq :draft
    end

    it 'returns nil if id is not recognized' do
      TestClass::PublishableEntity.find_status_by_id(999).should be_nil
    end
  end

  describe '::find_status_by_key' do
    it 'returns the status by its key' do
      TestClass::PublishableEntity.find_status_by_key(:draft).id.should eq 0
    end

    it 'returns nil if key is not recognized' do
      TestClass::PublishableEntity.find_status_by_key(:nope).should be_nil
    end
  end

  describe '::find_status_by_type' do
    it "returns an array of statuses for the given type" do
      TestClass::PublishableEntity.find_status_by_type(:pending)
        .map(&:key).should eq [:pending]
    end

    it "ignores unrecognized types" do
      TestClass::PublishableEntity.find_status_by_type(:nope)
        .map(&:key).should eq []
    end
  end

  describe '::status' do
    context 'with a block' do
      it "adds the status to the class" do
        TestClass::PublishableEntity.status :popular do |s|
          s.id = 9
          s.text = "Popular"
          s.published!
        end

        status = TestClass::PublishableEntity.find_status_by_key(:popular)
        status.key.should eq :popular
        status.id.should eq 9
        status.type.should eq :published
        status.text.should eq "Popular"

        TestClass::PublishableEntity.statuses.pop
      end
    end

    context "with a hash of attributes" do
      it "adds the status to the class" do
        TestClass::PublishableEntity.status :popular, {
          :id => 9,
          :text => "Popular",
          :type => :published
        }

        status = TestClass::PublishableEntity.find_status_by_key(:popular)
        status.key.should eq :popular
        status.id.should eq 9
        status.type.should eq :published
        status.text.should eq "Popular"

        TestClass::PublishableEntity.statuses.pop
      end
    end
  end


  # INSTANCE METHODS
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
      story = build :test_class_story,
        status: TestClass::Story.status_id(:draft)

      story.status_is?(:draft).should eq true
    end

    it "returns false if hte current status is not the given key" do
      story = build :test_class_story,
        status: TestClass::Story.status_id(:draft)

      story.status_is?(:live).should eq false
    end
  end

  describe '#status_was?' do
    it "returns true if the status was the given key" do
      story = create :test_class_story,
        status: TestClass::Story.status_id(:draft)

      story.status = TestClass::Story.status_id(:live)

      story.status_was?(:draft).should eq true
    end

    it "returns false if the status was not the given key" do
      story = create :test_class_story,
        status: TestClass::Story.status_id(:draft)

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
      story = build :test_class_story,
        status: TestClass::Story.status_id(:live)
      story.status_text.should eq "Published"
    end
  end

end
