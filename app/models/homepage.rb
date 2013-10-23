class Homepage < ActiveRecord::Base
  self.table_name = "layout_homepage"
  outpost_model
  has_secretary

  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::RedisPublishCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback
  include Concern::Methods::PublishingMethods


  TEMPLATES = {
    "default"    => "Visual Left",
    "lead_right" => "Visual Right",
    "wide"       => "Large Visual Top"
  }

  TEMPLATE_OPTIONS = TEMPLATES.map { |k, v| [v, k] }


  STATUS_DRAFT    = 0
  STATUS_PENDING  = 3
  STATUS_LIVE     = 5

  STATUS_TEXT = {
    STATUS_DRAFT      => "Draft",
    STATUS_PENDING    => "Pending",
    STATUS_LIVE       => "Live"
  }

  class << self
    def status_select_collection
      STATUS_TEXT.map { |k, v| [v, k] }
    end
  end

  #-------------------
  # Scopes

  #-------------------
  # Associations
  has_many :content,
    :class_name   => "HomepageContent",
    :order        => "position",
    :dependent    => :destroy

  accepts_json_input_for :content

  belongs_to :missed_it_bucket

  #-------------------
  # Validations
  validates :base, :status, presence: true

  #-------------------
  # Callbacks
  after_commit :expire_cache

  def expire_cache
    Rails.cache.expire_obj(self)
  end


  def published?
    self.status == STATUS_LIVE
  end

  def pending?
    self.status == STATUS_PENDING
  end

  def status_text
    STATUS_TEXT[self.status]
  end

  def publish
    self.update_attributes(status: STATUS_LIVE)
  end


  def articles
    @articles ||= self.content.includes(:content).map do |c|
      c.content.to_article
    end
  end


  def category_previews
    @category_previews ||= begin
      Category.previews(exclude: self.articles)
      .reject { |p| p.articles.empty? }
      .sort_by { |p| -p.articles.first.public_datetime.to_i }
    end
  end

  #---------------------


  private

  def build_content_association(content_hash, content)
    if content.published?
      HomepageContent.new(
        :position => content_hash["position"].to_i,
        :content  => content,
        :homepage => self
      )
    end
  end
end
