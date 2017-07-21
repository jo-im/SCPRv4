class PledgeDrive < ActiveRecord::Base
  outpost_model
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :current_dollars, :numericality => { :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :goal_dollars, :numericality => { :greater_than_or_equal_to => 0, :allow_nil => true }

  scope :enabled, ->{where(enabled: true)}
  scope :finished, ->{where('ends_at <= ?', Time.zone.now)}
  scope :happening, ->{enabled.where('starts_at < ?', Time.zone.now).where('ends_at > ?', Time.zone.now)}
  class << self
    def happening?
      happening.exists?
    end
  end

  def to_setting
    setting = Setting.new(context: 'global', key: "pledge_drive")
    setting.value = {
      starts_at: starts_at,
      ends_at: ends_at,
      current_dollars: current_dollars,
      goal_dollars: goal_dollars
    }
    setting
  end
end
