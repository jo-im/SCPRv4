class PledgeDrive < ActiveRecord::Base
  outpost_model
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  scope :enabled, ->{where(enabled: true)}
  scope :finished, ->{where('ends_at <= ?', Time.zone.now)}
  scope :happening, ->{enabled.where('starts_at < ?', Time.zone.now).where('ends_at > ?', Time.zone.now)}
  class << self
    def happening?
      happening.any?
    end
  end
end