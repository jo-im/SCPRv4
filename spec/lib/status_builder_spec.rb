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
end
