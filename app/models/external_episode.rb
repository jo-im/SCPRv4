class ExternalEpisode < ActiveRecord::Base
  # This also includes the admin routes, which we don't need.
  # Really that should be split into two modules, PublicRouting and
  # InternalRouting, or something.
  include Outpost::Model::Routing
  include Outpost::Model::Identifier

  include Concern::Associations::AudioAssociation
  self.public_route_key = "episode"

  belongs_to :external_program

  has_many :external_episode_segments,
    -> { order('position') }

  has_many :external_segments,
    -> { order("position") },
    through:    :external_episode_segments,
    dependent:  :destroy

  scope :for_air_date, ->(date_or_time) {
    where("DATE(air_date) = DATE(?)", date_or_time)
  }

  scope :expired, -> { joins(:external_program).where('CURRENT_DATE() >= DATE_ADD(external_episodes.created_at, INTERVAL days_to_expiry DAY)') }

  scope :published, -> { order("air_date desc") }

  scope :for_show_page, proc{ |page_number, per_page, current_episode|
    page(page_number).per(per_page)
  }

  # This needs to match ShowEpisode
  def route_hash
    return {} if !self.persisted?
    {
      :show           => self.external_program.slug,
      :year           => self.air_date.year.to_s,
      :month          => "%02d" % self.air_date.month,
      :day            => "%02d" % self.air_date.day,
      :id             => self.id.to_s,
      :trailing_slash => true
    }
  end


  def to_episode
    @to_episode ||= Episode.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.title,
      :summary            => self.summary,
      :air_date           => self.air_date,
      :audio              => self.audio.available,
      :program            => self.external_program.to_program,
      :segments           => self.external_segments.map(&:to_article)
    })
  end

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.title,
      :short_title        => self.title,
      :public_datetime    => self.air_date,
      :teaser             => self.summary,
      :body               => self.summary,
      :audio              => self.audio,
      :byline             => self.external_program.title
    })
  end
end
