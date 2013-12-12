class FeaturedComment < ActiveRecord::Base
  self.table_name = 'contentbase_featuredcomment'
  outpost_model
  has_secretary

  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Methods::PublishingMethods

  STATUS_DRAFT = 0
  STATUS_LIVE  = 5

  STATUS_TEXT = {
    STATUS_DRAFT => "Draft",
    STATUS_LIVE  => "Live"
  }

  #----------------
  # Scopes
  scope :published, -> {
    where(status: STATUS_LIVE)
    .order("created_at desc")
  }

  #----------------
  # Associations
  # FIXME: Remove reference to ContentBase.
  # See HomepageContent for explanation.
  belongs_to :content,
    :polymorphic    => true,
    :conditions     => { status: ContentBase::STATUS_LIVE }

  accepts_json_input_for :content

  belongs_to :bucket, class_name: "FeaturedCommentBucket"

  #----------------
  # Validation
  validates \
    :username,
    :status,
    :excerpt,
    :bucket_id,
    :content,
    presence: true

  #----------------
  # Callbacks

  #----------------

  class << self
    def status_select_collection
      STATUS_TEXT.map { |k, v| [v, k] }
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

  def build_content_association(content_hash, content)
    if content.published?
      self.content = content
    end
  end
end
