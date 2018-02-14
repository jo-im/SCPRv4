class ScheduleOccurrence < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Associations::PolymorphicProgramAssociation
  include Concern::Callbacks::TouchCallback
  include Concern::Sanitizers::Url

  before_validation ->{ sanitize_urls :info_url }

############################

  scope :after,   ->(time) { where("starts_at > ?", time).order("starts_at") }
  scope :before,  ->(time) { where("ends_at < ?", time).order("starts_at") }
  scope :future,  -> { after(Time.zone.now) }
  scope :past,    -> { before(Time.zone.now) }
  scope :current, -> { at(Time.zone.now) }

  scope :between, ->(start_date, end_date) {
    where("starts_at < ? and ends_at > ?", end_date, start_date)
    .order("starts_at")
  }

  scope :at, ->(date) {
    where("starts_at <= :date and ends_at > :date", date: date)
    .order("starts_at")
  }


  scope :recurring, -> { where("recurring_schedule_rule_id is not null") }
  scope :one_time,  -> { where("recurring_schedule_rule_id is null") }

  scope :filtered_by_date, ->(date) {
    system_time_zone = Time.now.formatted_offset
    rails_time_zone = Time.zone.now.formatted_offset
    where("DATE(CONVERT_TZ(starts_at, :system_tz, :rails_tz)) = :date", date: date, system_tz: system_time_zone, rails_tz: rails_time_zone)
    .order("starts_at")
  }

  scope :problems, ->{
    occurrences = future.order("starts_at ASC")
    analyzer = Schedulizer.new(occurrences)
    analyzer.problems
  }

############################

  validate :program_or_info_is_present
  validates :info_url, url: { allow_blank: true }


  belongs_to :recurring_schedule_rule

  before_update :detach_from_recurring_rule, if: -> {
    self.is_recurring? && (self.starts_at_changed? || self.ends_at_changed? || self.program_id_changed? || (self.event_title_changed? && self.info_url_changed?))
  }


  class << self
    def program_select_collection
      Program.all.map { |p| [p.title, p.obj_key] }
    end


    def date_select_collection
      self.select("distinct DATE(starts_at) as date")
      .order('date desc').map(&:date)
    end

    # Find the occurrence on at the requested date.
    # Distinct slots have higher priority. If there are any
    # distinct slots on at this date, then it will be returned.
    # Otherwise, it will return the first (recurring) slot.
    def on_at(date)
      occurrences = self.at(date)
      occurrences.find(&:is_distinct?) || occurrences.first
    end


    def block(date, length, collapse=false)
      occurrences = self.includes(:program).between(date, date + length).to_a

      occurrences.reject! do |occurrence|
        occurrences.any? do |o|
          o != occurrence && o.is_distinct? &&
          o.starts_at <= occurrence.starts_at &&
          o.ends_at >= occurrence.ends_at
        end
      end

      if collapse
        current = nil
        occurrences = occurrences.collect do |o|
          if current && o.program && current.program == o.program
            # add this to current
            current.ends_at = o.ends_at

            if o.updated_at > current.updated_at
              current.updated_at = o.updated_at
            end

            nil
          else
            current = o

            o
          end
        end.compact
      end

      occurrences
    end

  end

  def wday
    self.starts_at.wday
  end

  def duration
    self.ends_at.to_i - self.starts_at.to_i
  end

  def is_recurring?
    recurring_schedule_rule_id.present?
  end

  alias_method :recurring?, :is_recurring?

  def is_distinct?
    !self.is_recurring?
  end


  # Find the occurrence which is coming up next. This assumes that the
  # current object is currently on.
  def following_occurrence
    between = ScheduleOccurrence.between(Time.zone.now, self.ends_at + 1)
    between.find { |o| o != self }
  end


  # Validations will ensure that either the program or the event_title
  # is present.
  def title
    self.event_title.present? ? self.event_title : self.program.title
  end

  def public_url
    self.info_url.present? ? self.info_url : self.program.public_url
  end


  # This is for the listen live JS.
  def listen_live_json
    {
      :start => self.starts_at.to_i,
      :end   => self.ends_at.to_i,
      :title => self.title,
      :link  => self.public_url
    }
  end

  def display_name
    [program.try(:title), event_title].compact.join(" - ")
  end

  [:starts_at, :ends_at].each do |date|
    define_method "display_#{date}" do
      try(date).try(:strftime, "%I:%M%P %-m/%-d")
    end
  end

  def to_schedulizer_occurrence
    Schedulizer::Occurrence.new guid: id, 
                                starts_at: starts_at.to_i, 
                                ends_at: ends_at.to_i, 
                                precedence: schedulizer_precedence, 
                                created_at: created_at, 
                                metadata: {original_object: self, display_name: display_name}
  end

  private

  def schedulizer_precedence
    if recurring?
      0
    else
      1
    end
  end

  def detach_from_recurring_rule
    self.recurring_schedule_rule = nil
  end

  def program_or_info_is_present
    if self.program.blank? && (self.info_url.blank? || self.event_title.blank?)
      self.errors.add(:base, "Program or Info URL/Title must be present.")
    end
  end
end
