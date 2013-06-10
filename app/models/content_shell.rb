class ContentShell < ActiveRecord::Base
  self.table_name =  "contentbase_contentshell"
  outpost_model
  has_secretary
  
  include Concern::Scopes::SinceScope
  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Associations::AssetAssociation
  include Concern::Associations::BylinesAssociation
  include Concern::Associations::CategoryAssociation
  include Concern::Associations::HomepageContentAssociation
  include Concern::Associations::FeaturedCommentAssociation
  include Concern::Associations::MissedItContentAssociation
  include Concern::Validations::ContentValidation
  include Concern::Validations::PublishedAtValidation
  include Concern::Callbacks::CacheExpirationCallback
  include Concern::Callbacks::RedisPublishCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::StatusMethods
  include Concern::Methods::PublishingMethods
  
  def self.content_key
    "content/shell"
  end
  
  #-------------------
  # Scopes
  
  #------------------
  # Association
  
  #------------------
  # Validation
  validates :url, presence: true

  #------------------

  class << self
    def sites_select_collection
      ContentShell.select("distinct site").order("site").map(&:site)
    end
  end

  #------------------

  def needs_validation?
    self.pending? || self.published?
  end

  #------------------
  # Callbacks


  #-------------------
  # Sphinx  
  define_index do
    indexes headline
    indexes body
    indexes bylines.user.name, as: :bylines
    has category.id, as: :category
    has category.is_news, as: :category_is_news
    has published_at
    has updated_at
    has status
    has "1", as: :findable, type: :boolean
    has "CRC32(CONCAT('content/shell:',#{ContentShell.table_name}.id))", type: :integer, as: :obj_key
    has "1", as: :is_source_kpcc, type: :boolean
    has "0", as: :is_slideshow, type: :boolean
    has "0", as: :has_audio, type: :boolean
  end
  
  #-------------------
  
  def teaser
    self.body
  end
  
  def short_headline
    self.headline
  end

  #----------
  # Override Outpost's `link_path` for these
  def link_path(options={})
    self.url
  end
  
  def remote_link_path(options={})
    self.url
  end
  
  #----------
  
  def byline_extras
    [self.site]
  end

  #-------------------

  def to_article
    @to_article ||= Article.new({
      :original_object    => self,
      :id                 => self.obj_key,
      :title              => self.short_headline,
      :short_title        => self.short_headline,
      :public_datetime    => self.published_at,
      :teaser             => self.teaser,
      :body               => self.teaser,
      :assets             => self.assets,
      :attributions       => self.bylines,
      :byline             => self.byline,
      :permalink          => self.url
    })
  end

  #-------------------

  def to_abstract
    @to_abstract ||= Abstract.new({
      :original_object        => self,
      :headline               => self.short_headline,
      :summary                => self.teaser,
      :source                 => self.site,
      :url                    => self.url,
      :assets                 => self.assets,
      :category               => self.category,
      :article_published_at   => self.published_at
    })
  end
end
