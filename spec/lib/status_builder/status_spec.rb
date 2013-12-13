require 'spec_helper'

describe StatusBuilder::Status do
  it "sets the attributes from the hash on initialize" do
    status = StatusBuilder::Status.new(:live,
      { id: 10, type: :published, text: "Published" })

    status.key.should eq :live
    status.id.should eq 10
    status.type.should eq :published
    status.text.should eq "Published"
  end

  describe '#unpublished!' do
    it "sets the type to unpublished" do
      status = StatusBuilder::Status.new(:draft)
      status.type.should be_nil
      status.unpublished!
      status.type.should eq :unpublished
    end
  end

  describe '#pending!' do
    it "sets the type to pending" do
      status = StatusBuilder::Status.new(:pending)
      status.type.should be_nil
      status.pending!
      status.type.should eq :pending
    end
  end

  describe '#published!' do
    it "sets the type to published" do
      status = StatusBuilder::Status.new(:live)
      status.type.should be_nil
      status.published!
      status.type.should eq :published
    end
  end
end
