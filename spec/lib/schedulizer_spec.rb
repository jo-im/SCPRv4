require 'spec_helper'

describe Schedulizer do
  Timecop.freeze(Date.parse('2013-06-01')) do
    t = Time.zone.local(2013, 6, 1)
    describe '::gaps' do
      it "returns an array of gaps" do
        analyzer = Schedulizer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.25.hour), ends_at: (t + 2.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 1.1.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.4.day), ends_at: (t + 1.5.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 2.day))
        analyzer.find_gaps.map{|x| x.map(&:guid)}.should eq [[analyzer[2].guid, analyzer[3].guid]]
      end
    end

    describe '::overlaps' do
      it "returns an array of overlaps" do
        analyzer = Schedulizer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.25.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 1.1.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.4.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 2.day), recurring_schedule_rule_id: 1337)

        analyzer.find_overlaps.map{|x| x.map(&:guid)}.should eq [[analyzer[2].guid, analyzer[1].guid], [analyzer[4].guid, analyzer[5].guid]]
      end
      it "returns occurrences that overlap multiple occurrences" do
        analyzer = Schedulizer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 3.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 1.6.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.6.day), ends_at: (t + 1.7.day), recurring_schedule_rule_id: 1337)

        analyzer.find_overlaps.count.should eq 1
        analyzer.find_overlaps[0].length.should eq 4
        analyzer.find_overlaps[0].map(&:to_h).should =~ analyzer.last(4).map(&:to_h)
      end

      it "ignores non-recurring occurrences" do
        analyzer = Schedulizer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 3.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 1.6.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.6.day), ends_at: (t + 1.7.day), recurring_schedule_rule_id: 1337)

        analyzer.find_overlaps.should be_empty
      end

    end  
  end
end