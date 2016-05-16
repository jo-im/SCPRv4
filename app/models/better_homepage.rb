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

  after_create  :async_create_index
  after_update  :async_update_index
  after_destroy :async_destroy_index

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

  def to_indexable
    OpenStruct.new(
      {
        content:         content.map(&:to_indexable),
        check_it_out:    check_it_out.map(&:to_indexable),
        public_datetime: updated_at,
        published_at:    published_at
      }
    )
  end

  private

  def async_create_index
    # Only index if homepage is live.
    if status == self.class.status_id(:live)
      Job::HomepageIndexer.enqueue id, :create
    end
  end

  def async_update_index
    if status == self.class.status_id(:live)
      async_create_index
    else
      async_destroy_index
    end
  end

  def async_destroy_index
    Job::HomepageIndexer.enqueue id, :destroy
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
