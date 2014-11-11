# RecurringScheduleRule
#
# A recurring program on the schedule
#
# `start_time` and `end_time` are denormalized mostly just
# for the form. We could figure those attributes out from
# the `schedule_hash` but it's easier this way.
class RecurringScheduleRule < ActiveRecord::Base
  include IceCube

  serialize :schedule_hash, Hash
  serialize :days, Array

  outpost_model
  has_secretary

  include Concern::Associations::PolymorphicProgramAssociation
  include Concern::Callbacks::SphinxIndexCallback

  DEFAULT_INTERVAL = 1

  # Define a custom DAYS array so we can control the order.
  DAYS = [
    ["Monday", 1],
    ["Tuesday", 2],
    ["Wednesday", 3],
    ["Thursday", 4],
    ["Friday", 5],
    ["Saturday", 6],
    ["Sunday", 0]
  ]


  has_many :schedule_occurrences, dependent: :destroy


  validate :program_is_present

  validates :interval, presence: true
  validates :days, presence: true

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :time_fields_are_present


  before_save :build_schedule, if: :rule_changed?

  before_create :build_occurrences_through_next_month,
    :if => -> { self.schedule_occurrences.blank? }
  before_update :rebuild_occurrences, if: :rule_changed?

  # If they only updated the program, but not the rule, then we should fire
  # the callback to update all of the occurrence's programs.
  # If the rule was changed, then the occurrences are going to rebuilt
  # anyways, so the program will be updated from that.
  before_update :update_occurrence_program,
    :if => -> { self.program_changed? && !rule_changed? }


  class << self
    def create_occurrences(options={})
      self.all.each do |rule|
        rule.create_occurrences(options)
      end
    end
  end


  def schedule=(new_schedule)
    self.schedule_hash = new_schedule.try(:to_hash)
  end

  def schedule(options={})
    if self.schedule_hash.present?
      IceCube::Schedule.from_hash(self.schedule_hash, options)
    end
  end


  def duration
    @duration ||= begin
      start_time_seconds =
        calculate_seconds(parse_time_string(self.start_time))

      end_time_seconds =
        calculate_seconds(parse_time_string(self.end_time))

      return 0 unless start_time_seconds && end_time_seconds

      if start_time_seconds <= end_time_seconds
        end_time_seconds - start_time_seconds
      else
        1.day - start_time_seconds + end_time_seconds
      end
    end
  end


  def build_schedule
    self.schedule = ScheduleBuilder.build_schedule(
      interval:         self.interval,
      days:             self.days,
      start_time:       self.start_time,
      end_time:         self.end_time,
    )
  end


  # Build a block of occurrences of this rule.
  # This denormalization allows us to easily query for blocks of
  # schedule.
  #
  # Options:
  # * start_date - the date to start building (required)
  # * end_date   - the date to end building (required)
  #
  # Building events should be staggered.
  # You should build a month's worth of schedule,
  # starting at the beginning of the previous month, so you're
  # always a month ahead. This is just an example.
  #
  # Here's a diagram, for the visual learners out there:
  #
  #
  # DAY            :    01        01        01        01        01       ...
  # CURRENT MONTH  :    |---JAN---|---FEB---|---MAR---|---APR---|---JUN---|
  #                               |         |         |         |         |
  # BUILD SCH. FOR :             MAR       APR       JUN       JUL       etc
  #
  #
  # The periodic schedule building can be done by a cron job,
  # or lazily if you're feeling ambitious.
  #
  # By default (with no options passed in), this will build
  # a month worth of schedule starting now.
  #
  # Changing past occurrences is not recommneded. But, do whatever you
  # want. I'm just some words in a file. You don't have to listen to me.
  def build_occurrences(start_date:, end_date:)
    existing = existing_occurrences_between(start_date, end_date)

    # We don't want to duplicate occurrences that already exist
    # for this rule.
    self.schedule(start_date_override: start_date)
    .occurrences(end_date)
    .reject { |o| existing[o.start_time] }
    .each do |occurrence|
      self.schedule_occurrences.build(
        starts_at:      occurrence.start_time,
        ends_at:        occurrence.start_time + self.duration,
        soft_starts_at: occurrence.start_time + (self.soft_start_offset || 0),
        program:        self.program,
      )
    end

    self.schedule_occurrences
  end

  # Build and save
  def create_occurrences(args={})
    build_occurrences(args)
    self.save
  end

  # Rebuild and save
  def recreate_occurrences(args={})
    rebuild_occurrences(args)
    self.save
  end


  private

  # When a rule changes, we should just ditch all future occurrences of this
  # rule, and then rebuild from scratch. If a rule is changed
  # in the middle of a month, build_occurrences will only update a month's
  # worth of schedule occurrences, but we're building 2 months ahead of
  # time, so there will be some lingering occurrences that are no longer valid.
  #
  # For example (this actually happened):
  # On February 1st, the schedule is automatically populated for March by
  # a rake task. On Februrary 3rd, Colin changes the start time for a recurring
  # rule. This causes all occurrences between February 3rd and
  # March 3rd (1 month, the default duration) to be wiped out to make room
  # for the updated occurrences. But now March 3rd-March 31st still have these
  # incorrect occurrences. Even worse, they won't get fixed by the rake rask,
  # because the rake task no longer cares about March... the next time it runs
  # it will be for April.
  #
  # Now, unfortunately we have to keep the full schedule in sync with the
  # cron job that gets run monthly. On the first of each month, it builds
  # next month's schedule. If we destroy all future occurrences, and then
  # rebuild a month's worth from NOW, then come the middle of next month,
  # this rule will disappear from the schedule.
  #
  # How could we fix this hacky circumstance?
  # Lazily build the schedule, instead of building via cron job. This would
  # pretty much let us just delete all future occurrences whenever a rule
  # is changed, and let it be rebuilt as necessary. In some ways it's more
  # simple, but in many ways it's far more complicated.
  def rebuild_occurrences(args={})
    self.schedule_occurrences.future.destroy_all
    build_occurrences_through_next_month(args)
  end

  def build_occurrences_through_next_month(args={})
    args[:start_date] = Time.zone.now
    args[:end_date]   = 1.month.from_now.end_of_month

    build_occurrences(args)
  end


  # For the form...
  def program_is_present
    if self.program.blank?
      self.errors.add(:program_obj_key, "can't be blank.")
    end
  end

  def time_fields_are_present
    if self.start_time.blank? || self.end_time.blank?
      self.errors.add(:time, "can't be blank.")
    end
  end


  def update_occurrence_program
    self.schedule_occurrences.update_all(
      :program_id   => self.program_id,
      :program_type => self.program_type
    )
  end


  def parse_time_string(string)
    string.to_s.split(":").map(&:to_i)
  end

  def calculate_seconds(time_parts)
    return nil if time_parts.empty?
    time_parts[0] * 60 * 60 + time_parts[1] * 60
  end


  def duration_should_change?
    self.start_time_changed? ||
    self.end_time_changed?
  end

  def rule_changed?
    self.interval_changed? ||
    self.days_changed? ||
    self.start_time_changed? ||
    self.end_time_changed?
  end


  def rule_hash
    @rule_hash ||= self.schedule.recurrence_rules.first.try(:to_hash) || {}
  end

  def existing_occurrences_between(start_date, end_date)
    existing = {}

    self.schedule_occurrences
    .between(start_date, end_date).each do |occurrence|
      existing[occurrence.starts_at] = occurrence
    end

    existing
  end
end
