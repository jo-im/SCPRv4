class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true
  validates :tag_type, presence: true

  has_many :taggings, dependent: :destroy

  belongs_to :parent, polymorphic: true

  before_save :sanitize_tag_type, if: :tag_type_changed?

  def taggables(options={})
    ContentBase.search({ with: { "tags.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
  end

  def update_timestamps published_at
    if began_at.nil? || (published_at < began_at)
      self.update_attribute :began_at, published_at
    end

    if most_recent_at.nil? || (published_at > most_recent_at)
      self.update_attribute :most_recent_at, published_at
    end
  end

  def sanitize_tag_type
    self.tag_type = tag_type.titleize.chomp.strip.squeeze(" ")
  end
end
