require 'spec_helper'

describe Promise do
  let(:person) { create :test_class_person }

  it "runs on save given the condition passes" do
    person.should_receive(:update_index).once
    person.name = "Sean Keller"
    person.save!
  end

  it "doesn't run on save if the condition doesn't pass" do
    person.should_not_receive(:update_index)
    person.save!
  end

  it "runs on destroy given the conditions pass" do
    person.should_receive(:update_index).once
    person.destroy # checks `destroyed?`
  end
end
