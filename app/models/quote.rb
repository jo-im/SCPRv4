class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Associations::CategoryAssociation
  include Concern::Methods::PublishingMethods
  include Concern::Callbacks::SphinxIndexCallback

  STATUS_DRAFT = 0
  STATUS_LIVE = 5

  STATUS_TEXT = {
    STATUS_DRAFT => "Draft",
    STATUS_LIVE  => "Live"
  }

  FEATUREABLE_CLASSES = [
    "NewsStory",
    "BlogEntry",
    "ContentShell",
    "ShowSegment",
    "Event"
  ]


  scope :published, -> { where(status: STATUS_LIVE).order("created_at desc") }

  belongs_to :content,
    :polymorphic => true,
    :conditions  => { status: ContentBase::STATUS_LIVE }

  validates \
    :status,
    :category_id,
    :quote,
    presence: true

  validate :content_exists?, :content_is_published?

  #-----------------

  class << self
    def status_select_collection
      STATUS_TEXT.map { |k, v| [v, k] }
    end

    def featurable_classes_select_collection
      FEATUREABLE_CLASSES.map { |c| [c.titleize, c] }
    end
  end


  def article
    self.content.try(:to_article)
  end

  def published?
    self.status == STATUS_LIVE
  end

  def status_text
    STATUS_TEXT[self.status]
  end


  private

  def content_exists?
    if self.content_id && self.content_type && !self.content
      errors.add(:content_id, "Article doesn't exist. Check the ID.")
    end
  end

  #-----------------

  def content_is_published?
    if self.content && !self.content.published?
      errors.add(:content_id,
        "Article must be published in order to be featured.")
    end
  end
end
