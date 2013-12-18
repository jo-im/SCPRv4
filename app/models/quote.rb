class Quote < ActiveRecord::Base
  outpost_model
  has_secretary
  has_status


  include Concern::Associations::CategoryAssociation
  include Concern::Methods::StatusMethods
  include Concern::Callbacks::SphinxIndexCallback


  status :draft do |s|
    s.id = 0
    s.text = "Draft"
    s.unpublished!
  end

  status :live do |s|
    s.id = 5
    s.text = "Live"
    s.published!
  end


  # This uses created_at for sorting, not published_at,
  # so we can't use the PublishedScope concern.
  scope :published, -> {
    where(status: self.status_id(:live)).order("created_at desc")
  }

  belongs_to :content,
    -> { where(status: ContentBase::STATUS_LIVE) },
    :polymorphic => true

  accepts_json_input_for :content


  validates \
    :status,
    :category_id,
    :text,
    presence: true


  def article
    self.content.try(:to_article)
  end


  private

  def build_content_association(content_hash, content)
    if content.published?
      self.content = content
    end
  end
end
