class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Methods::PublishingMethods

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


  scope :published, -> {
    where(status: STATUS_LIVE)
    .order("created_at desc")
  }

  belongs_to :category
  belongs_to :article,
    polymorphic: true,
    conditions: {status: ContentBase::STATUS_LIVE }

  validates \
    :source_name,
    :source_context,
    :status,
    :category_id,
    :quote,
    :article_type,
    :article_id,
    presence: true

  validate :content_exists?, :content_is_published?

  #-----------------

  def content_exists?
    if self.article.nil?
      errors.add(:article_id, "Article doesn't exist. Check the ID.")
    end
  end

  #-----------------

  def content_is_published?
    if self.article && !self.article.published?
      errors.add(:article_id,
        "Article must be published in order to be featured.")
    end
  end

  class << self
    def status_select_collection
      STATUS_TEXT.map { |k, v| [v, k] }
    end

    def featurable_classes_select_collection
      FEATUREABLE_CLASSES.map { |c| [c.titleize, c] }
    end
  end


  def published?
    self.status == STATUS_LIVE
  end

  def status_text
    STATUS_TEXT[self.status]
  end
end
