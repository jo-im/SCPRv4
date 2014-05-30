class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true

  has_many :taggings, dependent: :destroy

  # This method allows us to get at the raw ThinkingSphinx Query object if
  # we need it (eg. for counting)
  def taggables(options={})
    ContentBase.search({ with: { tags: self.id } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options).map(&:to_article)
  end
end
