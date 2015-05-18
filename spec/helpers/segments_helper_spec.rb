require 'spec_helper'

describe SegmentsHelper do

  describe '#timestamp_if_segment_is_legacy' do
    context "the segment is 4 weeks behind the current episode air date" do
      it "returns html for a timestamp" do
        stamp = timestamp_if_segment_is_legacy(4.weeks.ago, Time.now)
        parsed_stamp = Nokogiri::HTML(stamp)
        expect(parsed_stamp.css("footer span time")).to_not be_empty
        expect(stamp.match(/\d{1,2}\/\d{1,2}\/\d{4}/i)).to_not be_nil
      end
    end

    context "the segment is fewer than 4 weeks behind the current episode air date" do
      it "returns html for a timestamp" do
        stamp = timestamp_if_segment_is_legacy(3.weeks.ago, Time.now)
        expect(stamp).to be_nil
      end
    end
  end

end