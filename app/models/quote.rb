class Quote < ActiveRecord::Base
  outpost_model
  has_secretary

  STATUS_DRAFT = 0
  STATUS_LIVE = 5

  STATUS_TEXT = {
    STATUS_DRAFT => "Draft",
    STATUS_LIVE  => "Live"
  }


  scope :published, -> {
    where(status: STATUS_LIVE)
    .order("created_at desc")
  }

  belongs_to :category
  belongs_to :article,
    polymorphic: true,
    conditions: {status: ContentBase::STATUS_LIVE }
  attr_accessible :quote, :source_context, :source_name

  def published?
    self.status == STATUS_LIVE
  end

end
