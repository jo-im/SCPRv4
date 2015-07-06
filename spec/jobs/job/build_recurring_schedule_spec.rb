require 'spec_helper'

describe Job::BuildRecurringSchedule do
  subject { described_class }
  it { subject.queue.should eq Job::QUEUES[:low_priority] }

  it "creates occurrences for next two weeks" do
    rule = create :recurring_schedule_rule
    rule.schedule_occurrences.destroy_all
    rule.schedule_occurrences(true).should be_blank

    Job::BuildRecurringSchedule.perform

    rule.reload

    start_date = Time.zone.now
    end_date = start_date + 2.weeks

    rule.schedule_occurrences
    .between(start_date, end_date)
    .should be_present

    rule.schedule_occurrences.before(start_date).should be_blank
    rule.schedule_occurrences.after(end_date).should be_blank
  end
end
