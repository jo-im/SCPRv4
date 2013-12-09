class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  include Concern::Methods::PublishingMethods
  include Concern::Callbacks::SphinxIndexCallback

  STATUS_DRAFT = 0
  STATUS_LIVE = 5

  STATUS_TEXT = {
    STATUS_DRAFT => "Draft",
    STATUS_LIVE  => "Live"
  }

  scope :published, -> { where(status: STATUS_LIVE).order("created_at desc") }

  belongs_to :category
  belongs_to :content,
    :polymorphic => true,
    :conditions  => { status: ContentBase::STATUS_LIVE }

  accepts_json_input_for :content

  validates \
    :status,
    :category_id,
    :quote,
    presence: true

  #-----------------

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
