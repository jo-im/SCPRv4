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
  include Concern::Model::Searchable

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

  # Build the schedule but not the actual occurrences.
  before_save :build_schedule, if: :rule_changed?

  before_create :build_two_weeks_of_occurrences,
    :if => -> { self.schedule_occurrences.blank? }
  before_update :recreate_two_weeks_of_occurrences, if: :rule_changed?

  # If they only updated the program, but not the rule, then we should fire
  # the callback to update all of the occurrence's programs.
  # If the rule was changed, then the occurrences are going to rebuilt
  # anyways, so the program will be updated from that.
  before_update :update_occurrence_program,
    :if => -> { self.program_changed? && !rule_changed? }


  class << self
    def recreate_occurrences options={}
      # The following creates new occurrences and then deletes the old ones.
      # This way there isn't a [noticeable] split second where the schedule
      # disappears or is missing occurrences.
      execute_then_destroy_old_occurrences do
        create_occurrences(options)
      end
    end
    def create_occurrences options={}
      all.each do |rule|
        if options.any?
          rule.create_occurrences(options)
        else
          rule.rebuild_two_weeks_of_occurrences
        end
      end
    end
    def execute_then_destroy_old_occurrences &block
      old_occurrences = ScheduleOccurrence.recurring.future.to_a
      ActiveRecord::Base.transaction do
        yield
        old_occurrences.each(&:destroy)
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
    schedule(start_date_override: start_date)
    .occurrences(end_date)
    .each do |occurrence|
      schedule_occurrences.build(
        starts_at:      occurrence.start_time,
        ends_at:        occurrence.start_time + duration,
        soft_starts_at: occurrence.start_time + (soft_start_offset || 0),
        program:        program,
      )
    end
    schedule_occurrences
  end

  def build_two_weeks_of_occurrences
    start_date = Time.zone.now
    end_date   = Time.zone.now + 2.weeks
    build_occurrences start_date: start_date, end_date: end_date
  end

  def create_two_weeks_of_occurrences
    build_two_weeks_of_occurrences
    schedule_occurrences.each(&:save!)
  end

  def recreate_two_weeks_of_occurrences
    execute_then_destroy_old_occurrences do
      create_two_weeks_of_occurrences
    end
  end

  # Build and save occurrences
  def create_occurrences(args={})
    build_occurrences(args)
    schedule_occurrences.each(&:save!)
  end

  # Remove old occurrences, create occurrences, and save.
  def recreate_occurrences(args={})
    execute_then_destroy_old_occurrences do
      create_occurrences(args)
    end
  end

  def problems
    occurrences = build_two_weeks_of_occurrences.to_a.reject!(&:id)
    occurrences.concat(
        ScheduleOccurrence.future.where.not(recurring_schedule_rule_id: self.id)
        )
      .sort_by!(&:starts_at)
    problems = ScheduleOccurrence.find_problems(occurrences)
    matcher = Proc.new {|p| p[0].recurring_schedule_rule_id == self.id || p[1].recurring_schedule_rule_id == self.id}
    problems = {
      related: {
        gaps: problems[:gaps].select(&matcher),
        overlaps: problems[:overlaps].select(&matcher)
      },
      other: {
        gaps: problems[:gaps].reject(&matcher),
        overlaps: problems[:overlaps].reject(&matcher),
      },
      all: problems,
      any?: problems[:any?]
    }
    problems[:related][:any?] = problems[:related][:gaps].any? || problems[:related][:overlaps].any?
    problems[:other][:any?]   = problems[:other][:gaps].any? || problems[:other][:overlaps].any?
    problems
  end

  private

  def execute_then_destroy_old_occurrences &block
    old_occurrences = schedule_occurrences.future.to_a
    ActiveRecord::Base.transaction do
      yield
      old_occurrences.each(&:destroy)
    end    
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
    self.end_time_changed? ||
    self.soft_start_offset_changed?
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
