class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :taggings, dependent: :destroy

  belongs_to :parent, polymorphic: true
  belongs_to :tag_type

  before_save :add_default_tag_type, unless: :tag_type_id?

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

  def add_default_tag_type
    if tag_type = TagType.where(name: "Keyword").first
      self.tag_type = tag_type
    end
  end

end
