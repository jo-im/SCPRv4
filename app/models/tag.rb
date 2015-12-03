class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :taggings, dependent: :destroy

  belongs_to :parent, polymorphic: true

  TYPES = ["Keyword", "Series", "Beat"]

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

  class << self
    def by_type
      list = []
      TYPES.each do |tag_type|
        list << OpenStruct.new(name: tag_type, tags: where(tag_type: tag_type))
      end
      list
    end
  end

end
