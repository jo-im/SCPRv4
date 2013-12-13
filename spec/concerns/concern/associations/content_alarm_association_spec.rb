require "spec_helper"

describe Concern::Associations::ContentAlarmAssociation do
  describe '#should_reject_alarm?' do
    it "rejects alarm is alarm doesn't exist and the fire_at fields are blank" do
      story = build :test_class_story, :pending
      story.alarm.should eq nil

      story.alarm_attributes = { "fire_at" => "" }
      story.save!

      story.alarm.should eq nil
    end
  end


  describe 'versioning' do
    it 'creates a new version when adding an alarm' do
      story = create :test_class_story, :pending
      story.versions.count.should eq 1

      # Without a fire_at, this will be marked for destruction by
      # rails.
      alarm = build :content_alarm, :future, content: nil
      story.alarm = alarm
      story.save!

      story.versions.count.should eq 2
      story.versions.last.object_changes["alarm"][1].keys.should eq ["fire_at"]

      story.versions.last.object_changes["alarm"][1]["fire_at"]
      .should eq alarm.fire_at
    end

    it 'creates a new version when removing an alarm' do
      # Set to pending so the alarm doesn't get destroyed on save
      story = build :test_class_story, :pending
      alarm = create :content_alarm, :future, content: nil
      story.alarm = alarm
      story.save!
      story.versions.count.should eq 1

      story.alarm = nil
      story.save!

      story.versions.count.should eq 2
      story.versions.last.object_changes["alarm"][1].should eq Hash.new
    end

    it "creates a new version when adding via nested form" do
      time = 1.hour.from_now
      story = create :test_class_story, :pending

      story.alarm_attributes = {
        "fire_at" => time
      }

      story.save!
      story.versions.count.should eq 2
      story.versions.last.object_changes["alarm"][1]["fire_at"].should eq time
    end

    it "creates a new version when removing via nested form" do
      alarm = build :content_alarm, content: nil, fire_at: 1.hour.from_now
      story = build :test_class_story, :pending
      story.alarm = alarm
      story.save!

      story.alarm_attributes = {
        "id" => alarm.id,
        "_destroy" => "1"
      }

      story.save!
      story.versions.count.should eq 2
      story.versions.last.object_changes["alarm"][1].should eq Hash.new
    end

    it "doesn't create a version when no attributes have changed" do
      time = 1.hour.from_now

      alarm = build :content_alarm, content: nil, fire_at: time
      # We have to set this to pending, otherwise a callback destroys the alarm.
      story = build :test_class_story, :pending
      story.alarm = alarm
      story.save!

      story.alarm_attributes = {
        "id" => alarm.id,
        "fire_at" => time.to_s
      }

      story.save!
      story.versions.count.should eq 1
    end
  end


  describe 'destroying an alarm' do
    it 'destroys the alarm if there was an alarm we went from pending to not pending' do
      story         = build :test_class_story, :pending
      story.alarm   = build :content_alarm, :pending
      story.save!

      story.reload.alarm.should be_present
      story.update_attribute(:status, story.class.status_id(:live))
      story.reload.alarm.should eq nil
    end

    it "doesn't destroy the alarm if status is still pending" do
      story         = build :test_class_story, :pending
      story.alarm   = build :content_alarm, :pending
      story.save!

      story.reload.alarm.should be_present
      story.update_attribute(:status, story.class.status_id(:pending))
      story.reload.alarm.should be_present
    end

    it "destroys the alarm if fire_at was set to nil" do
      story         = build :test_class_story, :pending
      story.alarm   = build :content_alarm, :pending
      story.save!

      story.reload.alarm.should be_present
      story.alarm.fire_at = nil
      story.save!

      story.reload.alarm.should eq nil
    end

    it "doesn't destroy the alarm if fire_at is changed" do
      story         = build :test_class_story, :pending
      story.alarm   = build :content_alarm, :pending
      story.save!

      story.reload.alarm.should be_present
      story.alarm.fire_at = Time.now.tomorrow
      story.save!

      story.reload.alarm.should be_present
    end
  end
end
