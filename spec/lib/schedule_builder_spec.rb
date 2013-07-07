require 'spec_helper'

describe ScheduleBuilder do
  describe '#start_time' do
    it "sets the start time" do
      builder = ScheduleBuilder.new(start_time: "11:00")
      builder.start_time.should eq "11:00"
    end
  end

  describe '#end_time' do
    it "sets the end time" do
      builder = ScheduleBuilder.new(end_time: "11:00")
      builder.end_time.should eq "11:00"
    end
  end

  describe '#duration' do
    it "calculates the duration from start_time and end_time" do
      builder = ScheduleBuilder.new(start_time: "10:00", end_time: "11:00")
      builder.duration.should eq 1.hour
    end

    it "is 0 if start time and end time not available" do
      builder = ScheduleBuilder.new(start_time: "10:00")
      builder.duration.should eq 0
    end

    it 'can bridge over-night' do
      builder = ScheduleBuilder.new(start_time: "23:00", end_time: "1:00")
      builder.duration.should eq 2.hours
    end
  end

  describe '#build_schedule' do
    it "builds a schedule from the information" do
      builder = ScheduleBuilder.new(
        :interval   => 2,
        :start_time => "11:00",
        :end_time   => "13:00",
        :days       => [1, 2, 3, 4]
      )

      schedule = builder.build_schedule
      schedule.duration.should eq 2.hours
    end

    it "returns nil if some required information is missing" do
      builder = ScheduleBuilder.new
      builder.build_schedule.should eq nil
    end
  end

  describe '::build_schedule' do
    it "builds a schedule from the information" do
      schedule = ScheduleBuilder.build_schedule(
        :interval   => 1,
        :start_time => "23:00",
        :end_time   => "01:00",
        :days       => []
      )

      schedule.duration.should eq 2.hours
    end

  end
end
