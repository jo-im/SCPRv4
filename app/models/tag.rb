class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :taggings, dependent: :destroy

  belongs_to :parent, polymorphic: true

  TYPES = ["Beat", "Series", "Keyword"]

  def taggables(options={})
    ContentBase.search({ with: { "tags.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
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
