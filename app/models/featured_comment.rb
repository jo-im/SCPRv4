class FeaturedComment < ActiveRecord::Base
  self.table_name = 'contentbase_featuredcomment'
  outpost_model
  has_secretary
  has_status


  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::HomepageCachingCallback
  include Concern::Methods::StatusMethods


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


  # FIXME: Remove reference to ContentBase.
  # See HomepageContent for explanation.
  belongs_to :content,
    :polymorphic    => true,
    :conditions     => { status: ContentBase::STATUS_LIVE }

  accepts_json_input_for :content

  belongs_to :bucket, class_name: "FeaturedCommentBucket"


  validates \
    :username,
    :status,
    :excerpt,
    :bucket_id,
    :content,
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
