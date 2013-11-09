class ShowSegment < ActiveRecord::Base
  self.table_name = 'shows_segment'
  outpost_model
  has_secretary

  include Concern::Scopes::SinceScope
  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Associations::RelatedContentAssociation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::BylinesAssociation
  include Concern::Associations::IssueArticleAssociation
  include Concern::Associations::CategoryAssociation
  include Concern::Associations::CategoryArticleAssociation
  include Concern::Associations::HomepageContentAssociation
  include Concern::Associations::FeaturedCommentAssociation
  include Concern::Associations::QuoteAssociation
  include Concern::Associations::MissedItContentAssociation
  include Concern::Associations::EditionsAssociation
  include Concern::Validations::ContentValidation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::GenerateSlugCallback
  include Concern::Callbacks::GenerateShortHeadlineCallback
  include Concern::Callbacks::GenerateTeaserCallback
  include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::RedisPublishCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::ContentStatusMethods
  include Concern::Methods::PublishingMethods
  include Concern::Methods::CommentMethods

  self.disqus_identifier_base = "shows/segment"
  ROUTE_KEY = "segment"

  ASSET_SCHEMES = [
    ["Top", "wide"],
    ["Right", "float"],
    ["Slideshow", "slideshow"],
    ["Video", "video"],
    ["Hidden", "hidden"]
  ]

  FEATURE_TYPE = ['Slideshow', 'Video', 'Poll', 'Map', 'Audio', 'Infographic']
  FEATURE_SET  = FEATURE_TYPE.each_with_index.map {|x,i| [x,i] }
  #-------------------
  # Scopes

  #-------------------
  # Associations
  belongs_to :show,
    :class_name   => "KpccProgram",
    :touch        => true

  has_many :rundowns,
    :class_name     => "ShowRundown",
    :foreign_key    => "segment_id",
    :dependent      => :destroy

  has_many :episodes,
    :through    => :rundowns,
    :source     => :episode,
    :order      => "air_date asc",
    :autosave   => true

  #-------------------
  # Validations
  validates :show, presence: true

  def needs_validation?
    self.pending? || self.published?
  end

  #-------------------
  # Callbacks

  #----------

  def episode
    @episode ||= episodes.first
  end

  #----------

  def sister_segments
    @sister_segments ||= begin
      if episodes.present?
        episode.segments.published.where("shows_segment.id != ?", self.id)
      else
        show.segments.published.where("shows_segment.id != ?", self.id).limit(5)
      end
    end
  end

  #----------

  def byline_extras
    [self.show.title]
  end

  #----------

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.show.slug,
      :year           => self.persisted_record.published_at.year.to_s,
      :month          => "%02d" % self.persisted_record.published_at.month,
      :day            => "%02d" % self.persisted_record.published_at.day,
      :id             => self.persisted_record.id.to_s,
      :slug           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end

  #-------------------

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.headline,
      :short_title        => self.short_headline,
      :public_datetime    => self.published_at,
      :teaser             => self.teaser,
      :body               => self.body,
      :category           => self.category,
      :assets             => self.assets,
      :audio              => self.audio.available,
      :attributions       => self.bylines,
      :byline             => self.byline,
      :edit_url           => self.admin_edit_url
    })
  end

  # This is a total hack, but unfortunately a necessary one
  # until we can fix the workflow of programs like filmweek:
  # those which use segments as episodes, and don't have any
  # literal "Episodes". What they should do (and basically
  # what we're mimicking here) is create an episode with a
  # single segment.
  # This just wraps itself in an Episode.
  def to_episode
    @to_episode ||= Episode.new({
      :original_object    => self,
      :id                 => "#{self.obj_key}-as_episode",
      :program            => self.show.to_program,
      :title              => self.short_headline,
      :summary            => self.teaser,
      :air_date           => self.published_at,
      :assets             => self.assets,
      :audio              => self.audio,
      :segments           => Array(self)
    })
  end

  #-------------------

  def to_abstract
    @to_abstract ||= Abstract.new({
      :original_object        => self,
      :headline               => self.short_headline,
      :summary                => self.teaser,
      :source                 => "KPCC",
      :url                    => self.public_url,
      :assets                 => self.assets,
      :audio                  => self.audio.available,
      :category               => self.category,
      :article_published_at   => self.published_at
    })
  end
end
