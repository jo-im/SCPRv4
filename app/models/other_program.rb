class OtherProgram < ActiveRecord::Base
  self.table_name =  'programs_otherprogram'
  outpost_model
  has_secretary

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include Concern::Validations::SlugValidation
  include Concern::Associations::RelatedLinksAssociation
  include Concern::Callbacks::SphinxIndexCallback

  ROUTE_KEY = "program"

  #-------------------
  # Scopes
  scope :active, -> { where(:air_status => ['onair','online']) }
  
  #-------------------
  # Associations
  has_many :recurring_schedule_rules, as: :program, dependent: :destroy


  #-------------------
  # Validations
  validates :title, :air_status, presence: true
  validates :slug, uniqueness: true
  
  # Temporary
  validates :podcast_url, presence: true, if: -> { self.rss_url.blank? }
  validates :rss_url, presence: true, if: -> { self.podcast_url.blank? }
  
  validate :rss_or_podcast_present
  def rss_or_podcast_present
    if self.podcast_url.blank? && self.rss_url.blank?
      errors.add(:base, "Must specify either a Podcast url or an RSS url")
      errors.add(:podcast_url, "")
      errors.add(:rss_url, "")
    end
  end
  
  #-------------------
  # Callbacks

  #-------------------
  # Sphinx  
  define_index do
    indexes title, sortable: true
    indexes teaser
    indexes description
    indexes host
    indexes produced_by
  end

  #-------------------
  
  class << self
    def select_collection
      OtherProgram.order("title").map { |p| [p.to_title, p.id] }
    end
  end

  #-------------------  
  # lame
  def display_segments
    false
  end
  
  def display_episodes
    false
  end

  def is_featured?
    false
  end

  #----------
  
  def published?
    self.air_status != "hidden"
  end
  
  #----------
  
  def route_hash
    return {} if !self.persisted? || !self.persisted_record.published?
    {
      :show           => self.persisted_record.slug,
      :trailing_slash => true
    }
  end
  
  #----------
  
  def cache
    if self.podcast_url.present?
      fetch_and_cache_feed(self.podcast_url, "podcast")
    end
    
    if self.rss_url.present?
      fetch_and_cache_feed(self.rss_url, "rss")
    end
  end

  #----------
  
  private
  
  def fetch_and_cache_feed(url, cache_suffix)
    cacher = CacheController.new
    
    Feedzirra::Feed.safe_fetch_and_parse(url) do |feed|
      cacher.cache(feed.entries.first(5), "/programs/cached/podcast_entry", "ext_program:#{self.slug}:#{cache_suffix}", local: :entries)
    end
  end

  add_transaction_tracer :cache, category: :task
end
