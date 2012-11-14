class ShowEpisode < ContentBase
  include Concern::Methods::StatusMethods
  include Concern::Methods::PublishingMethods
  include Concern::Methods::HeadlineMethods
  include Concern::Validations::ContentValidation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::AudioAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Scopes::SinceScope
  
  self.table_name = "shows_episode"
  ROUTE_KEY       = "episode"
  has_secretary
                    
  # -------------------
  # Administration
  administrate do
    define_list do
      list_order "published_at desc"
      
      column :headline
      column :show
      column :air_date
      column :status
      column :published_at
    end
  end
  
  
  # -------------------
  # Validations
  validates :show, presence: true
  validates :air_date, presence: true, if: :published?
  
  
  # -------------------
  # Associations
  belongs_to  :show,      class_name:   "KpccProgram"
  
  has_many    :rundowns,  class_name:   "ShowRundown", 
                          foreign_key:  "episode_id"
  
  has_many    :segments,  class_name:   "ShowSegment", 
                          foreign_key:  "segment_id", 
                          through:      :rundowns, 
                          order:        "segment_order asc"

    
  # -------------------
  # Scopes
  scope :published, -> { where(status: ContentBase::STATUS_LIVE).order("air_date desc, published_at desc") }
  scope :upcoming, -> { where(["status = ? and air_date >= ?",ContentBase::STATUS_PENDING,Date.today()]).order("air_date asc") }


  # -------------------
  # Callbacks
  before_validation :generate_headline, if: -> { self.headline.blank? }
  
  def generate_headline
    if self.air_date.present?
      self.headline = "#{self.show.title} for #{self.air_date.strftime("%B %-d, %Y")}"
    end
  end
  
  #--------------------
  # Teaser just returns the body.
  def teaser
    self.body
  end
  
  # -------------------
  
  define_index do
    indexes headline
    indexes body
    has show.id, :as => :program
    has "''", :as => :category, :type => :integer
    has "0", :as => :category_is_news, :type => :boolean
    has published_at
    has "1", :as => :is_source_kpcc, :type => :boolean
    has "CRC32(CONCAT('shows/episode:',shows_episode.id))", :type => :integer, :as => :obj_key
    has "0", :type => :boolean, :as => :is_slideshow
    has "COUNT(DISTINCT #{Audio.table_name}.id) > 0", :as => :has_audio, :type => :boolean
    where "status = #{ContentBase::STATUS_LIVE}"
    join audio
  end

  #----------
  
  def route_hash
    return {} if !self.published? || !self.persisted?
    {
      :show           => self.persisted_record.show.slug,
      :year           => self.persisted_record.air_date.year, 
      :month          => "%02d" % self.persisted_record.air_date.month,
      :day            => "%02d" % self.persisted_record.air_date.day,
      :trailing_slash => true
    }
  end
end
