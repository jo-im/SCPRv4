class Event < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status


  include Concern::Validations::SlugValidation
  include Concern::Associations::AudioAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Associations::CategoryAssociation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::FeaturedCommentAssociation
  include Concern::Associations::QuoteAssociation
  include Concern::Associations::HomepageContentAssociation
  include Concern::Associations::MissedItContentAssociation
  include Concern::Associations::VerticalArticleAssociation
  include Concern::Associations::ProgramArticleAssociation
  include Concern::Callbacks::GenerateSlugCallback
  include Concern::Callbacks::GenerateTeaserCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::CommentMethods
  include Concern::Methods::AssetDisplayMethods

  self.disqus_identifier_base = "events"
  self.public_route_key = "event"

  ForumTypes = [
    "comm",
    "cult",
    "hall"
  ]

  EVENT_TYPES = {
    'comm' => 'Forum: Community Engagement',
    'cult' => 'Forum: Cultural',
    'hall' => 'Forum: Town Hall',
    'spon' => 'Sponsored',
    'pick' => 'Staff Picks'
  }


  status :hidden do |s|
    s.id = 0
    s.text = "Hidden"
    s.unpublished!
  end

  status :live do |s|
    s.id = 5
    s.text = "Live"
    s.published!
  end


  scope :published, -> { where(status: self.status_id(:live)) }
  scope :forum,     -> { published.where("event_type IN (?)", ForumTypes) }
  scope :sponsored, -> { published.where("event_type = ?", "spon") }

  scope :upcoming, -> {
    published
    .where("starts_at > ?", Time.zone.now)
    .order("starts_at")
  }

  scope :upcoming_and_current, -> {
    published
    .where("ends_at > :now or starts_at > :now", now: Time.zone.now)
    .order("starts_at")
  }

  scope :past, -> {
    published
    .where("ends_at < :now", now: Time.zone.now)
    .order("starts_at desc")
  }


  belongs_to :kpcc_program


  validates \
    :headline,
    :status,
    presence: true

  validates \
    :event_type,
    :starts_at,
    :body,
    presence: true,
    :if => :should_validate?

  validates :location_url, :sponsor_url, url: { allow_blank: true }

  validates :rsvp_url, url: {
    :allow_blank    => true,
    :allowed        => [URI::HTTP, URI::MailTo]
  }


  def needs_validation?
    self.published?
  end


  class << self
    def event_types_select_collection
      EVENT_TYPES.map { |k,v| [v, k] }
    end

    def sorted(events, direction=:asc)
      case direction
      when :asc
        events.sort { |a,b| a.sorter <=> b.sorter }
      when :desc
        events.sort { |a,b| b.sorter <=> a.sorter }
      end
    end

    def closest
      upcoming.first
    end
  end


  def sorter
    ongoing? ? ends_at : starts_at
  end


  def ongoing?
    multiple_days? && current?
  end


  def multiple_days?
    minutes > 24*60
  end


  def minutes
    if self.ends_at.present?
      endt = self.ends_at
    else
      endt = self.starts_at.end_of_day
    end

    ((endt - starts_at) / 60).floor
  end


  # Still display maps, details, etc. if the event is currently happening
  def upcoming?
    starts_at > Time.zone.now
  end


  def current?
    if ends_at.present?
      Time.zone.now.between? starts_at, ends_at
    else
      Time.zone.now.between? starts_at, starts_at.end_of_day
    end
  end


  def is_forum_event?
    ForumTypes.include? self.event_type
  end


  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => "Event: " + self.headline,
      :short_title        => "Event: " + self.headline,
      :public_datetime    => self.starts_at,
      :teaser             => self.teaser,
      :body               => self.body,
      :assets             => self.assets,
      :audio              => self.audio.available,
      :byline             => "KPCC",
      :edit_url           => self.admin_edit_url
    })
  end


  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :year           => self.persisted_record.starts_at.year.to_s,
      :month          => "%02d" % self.persisted_record.starts_at.month,
      :day            => "%02d" % self.persisted_record.starts_at.day,
      :id             => self.id.to_s,
      :slug           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end
end
