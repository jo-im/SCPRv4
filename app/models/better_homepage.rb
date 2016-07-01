class BetterHomepage < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status

  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::PublishNotificationCallback
  include Concern::Model::Searchable
  # include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Associations::RelatedLinksAssociation

  status :draft do |s|
    s.id = 0
    s.text = "Draft"
    s.unpublished!
  end

  status :pending do |s|
    s.id = 3
    s.text = "Pending"
    s.pending!
  end

  status :live do |s|
    s.id = 5
    s.text = "Live"
    s.published!
  end

  has_many :content,
    -> { order('position') },
    :class_name   => "HomepageContent",
    :dependent    => :destroy,
    :as           => :homepage

  accepts_json_input_for :content
  tracks_association :content

  validates \
    :status,
    presence: true

  after_commit :cache

  scope :current, ->{ where(status: 5).order('published_at DESC').limit(1) }

  def publish
    self.update_attributes(status: self.class.status_id(:live))
  end

  def articles
    @articles ||= self.content.includes(:content).map do |c|
      c.content.to_article
    end
  end

  def category_previews
    @category_previews ||= begin
      Category.previews(exclude: self.articles)
    end
  end

  def content_articles
    ## This converts homepage content to 
    ## articles and includes the asset display
    ## scheme with it.
    content.includes(:content).map do |c| 
      article               = c.content.get_article
      article.asset_scheme  = c.asset_scheme
      article
    end
  end

  alias_method :check_it_out, :related_links

  def current?
    self.class.current.include?(self)
  end

  private

  def cache
    # Only index if homepage is current.
    if current?
      if Rails.env.development?
        sync_cache
      else
        async_cache
      end
    end
  end

  def sync_cache
    Job::BetterHomepageCache.perform
  end

  def async_cache
    Job::BetterHomepageCache.enqueue
  end

  def build_content_association(content_hash, content)
    ## These are defaults, but otherwise the content
    ## model should be able to receive whatever 
    ## attributes we throw at it.
    attrs = content_hash.merge({
      content: content,
      homepage: self,
      position: content_hash["position"].to_i
    })
    HomepageContent.new(attrs) if content.published?
  end

end
