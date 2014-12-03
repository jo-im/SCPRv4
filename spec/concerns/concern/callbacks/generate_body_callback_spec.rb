require 'spec_helper'

describe Concern::Callbacks::GenerateBodyCallback do
  describe '#generate_body' do
    it "runs before validation if article body is blank" do
      story = build :test_class_story, body: nil, teaser: "Hello"
      story.save!
      story.body.should eq "Hello"
    end

    it "doesn't run if body is present" do
      story = build :test_class_story, body: "Okay", teaser: "Okedoke"
      story.save!
      story.body.should eq "Okay"
    end
  end
end
