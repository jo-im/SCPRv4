class BetterHomepage < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status

  include Concern::Scopes::PublishedScope
  include Concern::Associations::ContentAlarmAssociation
  include Concern::Callbacks::SetPublishedAtCallback
  include Concern::Callbacks::PublishNotificationCallback
  include Concern::Model::Searchable
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Callbacks::TouchCallback

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
      article               = c.content.to_article
      article.asset_display = c.asset_display
      article
    end
  end

  def to_index
    Hashie::Mash.new(
      {
        content:         content.map(&:to_index),
        public_datetime: updated_at,
        published_at:    published_at
      }
    )
  end

  private

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
