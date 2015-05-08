class Tag < ActiveRecord::Base
  outpost_model
  has_secretary

  validates :slug, uniqueness: true
  validates :title, presence: true

  has_many :taggings, dependent: :destroy

  def taggables(options={})
    ContentBase.search({ with: { "tags.slug" => self.slug } }.reverse_merge(options))
  end

  def articles(options={})
    taggables(options)
  end

  def update_timestamps published_at
    updates = {}

    if began_at && (published_at < began_at) || began_at.nil?
      updates[:began_at] = published_at
    end

    if most_recent_at && (published_at > most_recent_at) || most_recent_at.nil?
      updates[:most_recent_at] = published_at
    end

    update(updates) if updates.any?
    self
  end

  private

  def connection
    self.class.superclass.connection
  end

end
