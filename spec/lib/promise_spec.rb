require 'spec_helper'

describe Promise do
  let(:person) { build :test_class_person }

  it "runs on save given the condition passes" do
    person.should_receive(:touch_associated).once
    person.save!
    person.destroy
  end

  it "doesn't run on save if the condition doesn't pass" do
    person.should_not_receive(:touch_associated)
    person.save!
    person.destroy
  end

  it "runs on destroy given the conditions pass" do
    person.should_receive(:update_index).once
    person.save!
    person.destroy
  end

  it "doesn't run on destroy if the conditions don't pass" do
    person.should_not_receive(:update_index)
    person.save!
    person.destroy
  end
end
