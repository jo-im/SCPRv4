class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true

  has_many :taggings, dependent: :destroy

  def articles(options={})
    ContentBase.search({ with: { tags: self.id } }.reverse_merge(options))
    .map(&:to_article)
  end
end
