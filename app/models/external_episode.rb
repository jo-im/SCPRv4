class ExternalEpisode < ActiveRecord::Base
  # This also includes the admin routes, which we don't need.
  # Really that should be split into two modules, PublicRouting and
  # InternalRouting, or something.
  include Outpost::Model::Routing
  include Outpost::Model::Identifier

  include Concern::Associations::AudioAssociation
  self.public_route_key = "episode"

  belongs_to :program, class_name: :ExternalProgram, foreign_key: "external_program_id"

  has_many :external_episode_segments,
    -> { order('external_episode_segments.position asc') }

  has_many :segments,
    through:    :external_episode_segments,
    dependent:  :destroy,
    class_name: :ExternalSegment

  scope :for_air_date, ->(date_or_time) {
    where("DATE(air_date) = DATE(?)", date_or_time)
  }

  scope :published, -> { order("air_date desc") }

  scope :duplicates, -> { 
    where.not(id: select("MAX(id) as id").group([:title, :external_program_id]).pluck(:id))
  }

  # This needs to match ShowEpisode
  def route_hash
    return {} if !self.persisted?
    {
      :show           => self.program.slug,
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
      :program            => self.program,
      :segments           => self.segments.map(&:to_article)
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
      :byline             => self.program.title,
      :abstract           => self.abstract
    })
  end

end
