# ExternalProgram is a Program that comes from an outside source,
# such as an API or an RSS feed.
#
# To add an importer:
#
# 1. Write your importer. Place it in the `app/importers` directory.
#    It only needs to respond to the `sync` class method, which accepts
#    the program as its only argument.
#    This method should fetch the segments (in an RSS feed these would be the
#    entries) and save them to our database. But it can do whatever you want.
#    I'm not here to tell you what to do.
# 2. Add it to the IMPORTERS hash. The key is the arbitrary text ID for the
#    importer, and the value is the class name.
# 3. Set the program to use that importer in the CMS.
# 4. There's not a 4th step, get to work already.
#
# We keep the podcast_url attribute on this table (instead of as a related link)
# so that we can more easily validate it, and so we're not tying the behavior
# of this model to an associated model.
#
class ExternalProgram < ActiveRecord::Base
  outpost_model
  has_secretary

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include Concern::Validations::SlugValidation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Associations::PodcastAssociation
  include Concern::Model::Searchable
  include Concern::Model::Programs
  include Concern::Sanitizers::Url

  self.public_route_key = "program"

  # "source" => "Importer module name"
  IMPORTERS = {
    "npr-api" => "NprProgramImporter",
    "rss"     => "RssProgramImporter"
  }


  #-------------------
  # Scopes
  scope :active, -> { where(air_status: ['onair', 'online']) }
  scope :with_expiration, -> { where.not(days_to_expiry: nil, days_to_expiry: 0) }

  #-------------------
  # Associations
  has_many :recurring_schedule_rules, as: :program, dependent: :destroy
  has_many :episodes, dependent: :destroy, class_name: :ExternalEpisode, dependent: :destroy
  has_many :segments, class_name: :ExternalSegment, dependent: :destroy

  #-------------------
  # Validations
  validates \
    :title,
    :air_status,
    :source,
    presence: true

  validates :podcast_url, presence: true, url: true
  validates :slug, presence: true, uniqueness: true
  validate :slug_is_unique_in_programs_namespace

  #-------------------
  # Callbacks

  #-------------------

  #-------------------
  # Aliases
  # alias_attribute :episodes, :external_episodes
  #-------------------

  #-------------------
  # Sanitizers
  before_save ->{ sanitize_urls :podcast_url }
  #-------------------

  class << self
    def select_collection
      ExternalProgram.order("title").map { |p| [p.to_title, p.id] }
    end

    def sync(source=nil)
      finder = self.active

      if source
        finder = finder.where(source:source)
      end

      finder.each(&:sync)
    end
  end

  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end

  def rss_url
    self.get_link('rss')
  end

  def published?
    self.air_status != "hidden"
  end

  def importer
    @importer ||= IMPORTERS[self.source].constantize
  end

  def sync
    self.importer.sync(self)
  end

  def is_segmented?
    true
  end

  def expired_episodes
    if has_episode_expiration?
      self.episodes.where("air_date < ?",self.days_to_expiry.days.ago).includes(:audio,:segments)
    else
      []
    end
  end

  def has_episode_expiration?
    !days_to_expiry.nil? && days_to_expiry != 0
  end

  def is_kpcc
    false
  end

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.title,
      :short_title        => self.title,
      :public_datetime    => self.created_at,
      :teaser             => self.description,
      :body               => self.description,
      :assets             => [],
      :attributions       => [ContentByline.new(name: self.host)],
      :byline             => self.host,
      :edit_path          => self.admin_edit_path,
      :public_path        => self.public_path,
      :tags               => [],
      :feature            => [],
      :created_at         => self.created_at,
      :updated_at         => self.updated_at,
      :published          => true,
      :related_content    => [],
      :links              => [],
      :asset_display      => "photo"
    })
  end

  def obj_key
    if id
      "external_program-#{id}"
    end
  end

  private

  def slug_is_unique_in_programs_namespace
    if self.slug.present? && KpccProgram.exists?(slug: self.slug)
      self.errors.add(:slug, "must be unique between both " \
                             "KpccProgram and ExternalProgram")
    end
  end
end
