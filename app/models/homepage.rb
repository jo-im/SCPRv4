class Homepage < ActiveRecord::Base
  self.table_name = "layout_homepage"
  outpost_model
  has_secretary
  has_status


  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::RedisPublishCallback
  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback


  TEMPLATES = {
    "default"    => "Visual Left",
    "lead_right" => "Visual Right",
    "wide"       => "Large Visual Top"
  }

  TEMPLATE_OPTIONS = TEMPLATES.invert


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
    :dependent    => :destroy

  accepts_json_input_for :content
  tracks_association :content

  belongs_to :missed_it_bucket


  validates \
    :base,
    :status,
    presence: true


  after_commit :expire_cache


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


  private

  def expire_cache
    Rails.cache.expire_obj(self)
  end


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
