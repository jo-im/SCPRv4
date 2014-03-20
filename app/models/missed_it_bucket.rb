class MissedItBucket < ActiveRecord::Base
  self.table_name = "contentbase_misseditbucket"
  outpost_model
  has_secretary

  include Concern::Callbacks::SphinxIndexCallback
  include Concern::Callbacks::TouchCallback

  has_many :content,
    -> { order('position') },
    :class_name     => "MissedItContent",
    :foreign_key    => "bucket_id",
    :dependent      => :destroy

  accepts_json_input_for :content
  tracks_association :content


  validates :title, :slug, presence: true


  before_validation :generate_slug, if: -> { self.slug.blank? }
  after_commit :expire_cache


  def articles(limit=nil)
    @articles ||= self.content.includes(:content).limit(limit).map do |c|
      c.content.to_article
    end
  end


  private

  def expire_cache
    Rails.cache.expire_obj(self)
  end

  def generate_slug
    if self.title.present?
      self.slug = self.title.parameterize[0...50].sub(/-+\z/, "")
    end
  end

  def build_content_association(content_hash, content)
    if content.published?
      MissedItContent.new(
        :position         => content_hash["position"].to_i,
        :content          => content,
        :missed_it_bucket => self
      )
    end
  end
end
