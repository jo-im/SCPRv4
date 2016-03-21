require 'spec_helper'

describe ScheduleAnalyzer do
  Timecop.freeze(Date.parse('2013-06-01')) do
    t = Time.zone.local(2013, 6, 1)
    describe '::gaps' do
      it "returns an array of gaps" do
        analyzer = ScheduleAnalyzer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.25.hour), ends_at: (t + 2.hour))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 1.1.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.4.day), ends_at: (t + 1.5.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 2.day))
        analyzer.gaps.should eq [[analyzer[2], analyzer[3]]]
      end
    end

    describe '::overlaps' do
      it "returns an array of overlaps" do
        analyzer = ScheduleAnalyzer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.25.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 1.1.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.4.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 2.day), recurring_schedule_rule_id: 1337)

        analyzer.overlaps.should eq [[analyzer[2], analyzer[1]], [analyzer[4], analyzer[5]]]
      end
      it "returns occurrences that overlap multiple occurrences" do
        analyzer = ScheduleAnalyzer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 3.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 1.6.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.6.day), ends_at: (t + 1.7.day), recurring_schedule_rule_id: 1337)

        analyzer.overlaps.count.should eq 1
        analyzer.overlaps[0].length.should eq 4
        analyzer.overlaps[0].should =~ analyzer.last(4)
      end

      it "ignores non-recurring occurrences" do
        analyzer = ScheduleAnalyzer.new
        analyzer << create(:schedule_occurrence, starts_at: t, ends_at: (t + 1.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.hour), ends_at: (t + 1.5.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.hour), ends_at: (t + 2.hour), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.day), ends_at: (t + 3.day))
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.1.day), ends_at: (t + 1.5.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.5.day), ends_at: (t + 1.6.day), recurring_schedule_rule_id: 1337)
        analyzer << create(:schedule_occurrence, starts_at: (t + 1.6.day), ends_at: (t + 1.7.day), recurring_schedule_rule_id: 1337)

        analyzer.overlaps.should be_empty
      end

    end  
  end
end