require 'spec_helper'

describe RecurringScheduleRule do
  describe 'validations' do
    it "validates program presence, but also adds the program_obj_key to the errors" do
      rule = build :recurring_schedule_rule, program: nil, program_obj_key: nil
      rule.valid?.should eq false
      rule.errors.keys.should include :program_obj_key
    end

    it "adds time to errors if start_time or end_time blank" do
      rule = build :recurring_schedule_rule, start_time: nil
      rule.valid?.should eq false
      rule.errors.keys.should include :time
      rule.errors.keys.should include :start_time
    end
  end

  describe '::create_occurrences' do
    it "creates occurrences for all rules" do
      rules = create_list :recurring_schedule_rule, 3
      ScheduleOccurrence.destroy_all
      ScheduleOccurrence.count.should eq 0

      t = Time.new(2013, 1, 1)
      RecurringScheduleRule.create_occurrences(start_date: t, end_date: t + 1.week)
      ScheduleOccurrence.count.should be > 0
    end
  end

  describe 'changing the program' do
    it "changes all the occurrence's program as well" do
      rule = create :recurring_schedule_rule
      rule.schedule_occurrences.first.program.should eq rule.program

      # Reload to clear out cached associations
      rule.reload

      another_program = create :kpcc_program, title: "Updated Program"
      rule.program = another_program
      rule.save!
      rule.schedule_occurrences.first.program.should eq another_program
    end
  end

  describe '#duration' do
    it "calculates the duration from start_time and end_time" do
      rule = build :recurring_schedule_rule, start_time: "09:00", end_time: "11:00"
      rule.duration.should eq 2.hours
    end

    it "is 0 if start time and end time not available" do
      rule = build :recurring_schedule_rule, start_time: "09:00", end_time: nil
      rule.duration.should eq 0
    end

    it 'can bridge over-night' do
      rule = build :recurring_schedule_rule, start_time: "23:00", end_time: "1:00"
      rule.duration.should eq 2.hours
    end
  end

  describe 'schedule' do
    let(:rule) { build :recurring_schedule_rule }
    let(:schedule) {
      ScheduleBuilder.build_schedule(
        :interval     => rule.interval,
        :days         => rule.days,
        :start_time   => rule.start_time,
        :end_time     => rule.end_time
      )
    }

    it "sets the schedule to the passed-in Schedule object to_hash" do
      rule.schedule = schedule

      # We have to check to_s since Schedule doesn't have a custom
      # comparison method defined and will fail if they're not the
      # same object (they won't be sincle #schedule uses Schedule#from_hash)
      rule.schedule.to_s.should eq schedule.to_s
    end
  end

  describe '#build_schedule' do
    it "builds a new schedule on create" do
      rule = build :recurring_schedule_rule
      rule.schedule.should eq nil

      rule.save!
      rule.schedule.should_not eq nil
    end

    it "builds a new schedule on save if rule changed" do
      rule = build :recurring_schedule_rule
      rule.save!
      original_schedule = rule.schedule

      rule.days = [1, 3, 4]
      rule.save!
      rule.schedule.should_not eq original_schedule
    end
  end

  describe '#build_occurrences' do
    let(:rule) {
      build :recurring_schedule_rule,
      :days         => [1],
      :start_time   => "0:00",
      :end_time     => "1:00"
    }

    before :each do
      # Can't use let here because it gets evaluated into UTC time
      Time.stub(:now) { Time.new(2013, 7, 1) }

      rule.build_schedule
    end

    it "runs on create if schedule_occurrences is blank" do
      rule.schedule_occurrences.should be_blank
      rule.save!
      rule.schedule_occurrences.should be_present
    end

    it "doesn't run if schedule_occurrences is present" do
      rule.build_occurrences(start_date: Time.now, end_date: Time.now + 1.month)
      rule.should_not_receive(:build_occurrences)
      rule.save!
    end

    it "uses the passed-in start_date" do
      rule.build_occurrences(start_date: Time.now+1.month, end_date: Time.now+2.month)
      rule.schedule_occurrences.first.starts_at.should be >= Time.now+1.month
    end

    it "only builds up to the end_date" do
      rule.build_occurrences(start_date: Time.now, end_date: Time.now+1.week)
      rule.schedule_occurrences.after(Time.now + 1.week).should be_empty
    end

    it "sets the ends_at of the occurrence to starts_at + duration" do
      rule.build_occurrences(start_date: Time.now, end_date: Time.now + 1.month)
      rule.schedule_occurrences.first.duration.should eq 1.hour
    end

    it "doesn't duplicate already-existing occurrences" do
      rule.save!
      rule.schedule_occurrences.count.should eq 9

      rule.create_occurrences(start_date: Time.now, end_date: Time.now+2.months)
      rule.schedule_occurrences(true).count.should eq 9

      rule.create_occurrences(start_date: Time.now, end_date: Time.now+3.months)
      rule.schedule_occurrences(true).count.should be > 9
    end
  end

  describe '#create_occurrences' do
    it 'builds occurrences and then saves' do
      Time.stub(:now) { Time.new(2013, 7, 1) }

      rule = create :recurring_schedule_rule,
        :days         => [1],
        :start_time   => "0:00",
        :end_time     => "1:00"

      rule.schedule_occurrences.destroy_all

      rule.schedule_occurrences.count.should eq 0
      rule.create_occurrences(start_date: Time.now, end_date: Time.now + 1.month)
      rule.reload.schedule_occurrences.count.should eq 5
    end
  end

  describe '#recreate_occurrences' do
    let(:rule) {
      build :recurring_schedule_rule,
      :days         => [1],
      :start_time   => "1:00",
      :end_time     => "2:00"
    }

    it 'rebuilds and then saves' do
      Time.stub(:now) { Time.new(2013, 7, 1) }
      rule.save!
      rule.schedule_occurrences.count.should eq 9

      rule.schedule_occurrences.destroy_all

      rule.recreate_occurrences
      rule.schedule_occurrences(true).count.should eq 9
    end
  end

  describe '#rebuild_occurrences' do
    let(:rule) {
      build :recurring_schedule_rule,
      :days         => [1],
      :start_time   => "1:00",
      :end_time     => "2:00"
    }

    before do
      Time.stub(:now) { Time.new(2013, 7, 1) }
      rule.save!

      # It makes 2 months worth. There are 5 mondays in this month.
      rule.schedule_occurrences.count.should eq 9
    end

    it "destroys and replaces all future occurrences" do
      rule.schedule_occurrences.all? { |o| o.starts_at.wday == 1 }.should be_true

      # Change the rule and save to trigger rebuilding
      rule.days = [2]
      rule.save!

      rule.schedule_occurrences(true).all? { |o| o.starts_at.wday == 2 }.should be_true
    end

    it "rebuilds occurrences through the end of next month" do
      rule.days = [2]
      rule.save!

      rule.schedule_occurrences(true).last.starts_at.month.should eq Time.now.next_month.month
    end

    it "gets run on update if the rule has changed" do
      rule.save!
      rule.days = [2]
      rule.save!
      rule.schedule_occurrences.last.starts_at.wday.should eq 2
    end
  end
end
