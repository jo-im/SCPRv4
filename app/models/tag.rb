class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true

  has_many :taggings, dependent: :destroy

  def taggables(options={})
    ContentBase.search({ with: { "tag.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
  end
end
