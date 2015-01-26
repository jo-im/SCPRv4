require 'spec_helper'

describe Concern::Callbacks::GenerateBodyCallback do
  describe '#generate_body' do
    it "runs before validation if segment body is blank" do
      segment = build :show_segment, body: nil, teaser: "Hello"
      segment.save!
      segment.body.should eq "Hello"
    end

    it "doesn't run if body is present" do
      segment = build :show_segment, body: "Okay", teaser: "Okedoke"
      segment.save!
      segment.body.should eq "Okay"
    end
  end
end
