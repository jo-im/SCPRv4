require "spec_helper"

describe ShowRundown do
  describe "associations" do
    it { should belong_to(:episode).class_name("ShowEpisode") }
    it { should belong_to(:segment).class_name("ShowSegment") }
  end
end
