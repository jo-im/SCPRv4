class ShowEpisode < ActiveRecord::Base
  self.table_name = "shows_episode"
  outpost_model
  has_secretary

  include Concern::Scopes::SinceScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::RedisPublishCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::ContentStatusMethods
  include Concern::Methods::PublishingMethods

  ROUTE_KEY = "episode"

  #-------------------
  # Scopes
  scope :published, -> {
    where(status: ContentBase::STATUS_LIVE)
    .order("air_date desc, published_at desc")
  }

  scope :upcoming, -> {
    where(status: ContentBase::STATUS_PENDING)
    .where("air_date >= ?", Date.today)
    .order("air_date asc")
  }

  scope :for_air_date, ->(date_or_time) {
    where("DATE(air_date) = DATE(?)", date_or_time)
  }


  belongs_to :show,
    :class_name  => "KpccProgram",
    :touch       => true

  has_many :rundowns,
    :class_name     => "ShowRundown",
    :foreign_key    => "episode_id",
    :dependent      => :destroy

  has_many :segments,
    :class_name     => "ShowSegment",
    :foreign_key    => "segment_id",
    :through        => :rundowns,
    :order          => "position"


  accepts_json_input_for :rundowns
  tracks_association :rundowns


  validates :show, presence: true
  validates :status, presence: true
  validates :air_date, presence: true, if: :should_validate?

  validates :body, :presence => {
    :message => "can't be blank when publishing",
    :if      => :should_validate?
  }


  before_save :generate_headline,
    :if => -> { self.headline.blank? }


  def needs_validation?
    self.pending? || self.published?
  end


  # For podcasts
  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.headline,
      :short_title        => self.headline,
      :public_datetime    => self.published_at,
      :body               => self.body,
      :teaser             => self.body,
      :assets             => self.assets,
      :audio              => self.audio.available,
      :byline             => self.show.title,
      :edit_url           => self.admin_edit_url
    })
  end


  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.show.slug,
      :year           => self.persisted_record.air_date.year.to_s,
      :month          => "%02d" % self.persisted_record.air_date.month,
      :day            => "%02d" % self.persisted_record.air_date.day,
      :id             => self.id.to_s,
      :trailing_slash => true
    }
  end

  def to_episode
    @to_episode ||= Episode.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.headline,
      :summary            => self.body,
      :air_date           => self.air_date,
      :assets             => self.assets,
      :audio              => self.audio.available,
      :program            => self.show.to_program,
      :segments           => self.segments.published.map(&:to_article)
    })
  end


  private

  def generate_headline
    if self.air_date.present? && self.show.present?
      self.headline = "#{self.show.title} for " \
        "#{self.air_date.strftime("%B %-d, %Y")}"
    end
  end

  def build_rundown_association(rundown_hash, segment)
    if segment.is_a? ShowSegment
      ShowRundown.new(
        :position => rundown_hash["position"].to_i,
        :segment  => segment
      )
    end
  end
end
